#!/bin/bash

# 获取最大分区
max_partition=$(df --output=target,size | awk 'NR>1 {print $2,$1}' | sort -nr | head -n 1 | cut -d' ' -f2)

# 默认安装路径
DEFAULT_INSTALL_DIR="$max_partition/data/app/oracle"

# 确认安装路径
confirm_installation_path() {
    local MAX_PARTITION_DIR="$max_partition"
    local INSTALL_PATH_FILE="/tmp/install_path.txt"

    if [[ -f "$INSTALL_PATH_FILE" ]]; then
        # 如果文件存在，读取安装路径
        INSTALL_DIR=$(<"$INSTALL_PATH_FILE")
        echo "检测到上次保存的安装路径：$INSTALL_DIR"
        return 0
    else
        read -p "是否使用默认安装路径 ($DEFAULT_INSTALL_DIR 在最大分区 $max_partition 中)? (y/n): " use_default
        if [[ $use_default =~ ^[Yy]$ ]]; then
            INSTALL_DIR="$DEFAULT_INSTALL_DIR"
            echo "$INSTALL_DIR" > "$INSTALL_PATH_FILE"
            return 0
        else
            # 用户指定安装路径
            read -p "请输入自定义安装路径: " USER_SPECIFIED_DIR
            INSTALL_DIR="$USER_SPECIFIED_DIR"
            echo "$INSTALL_DIR" > "$INSTALL_PATH_FILE"
            return 1
        fi
    fi
}

# 函数：添加注释
add_comment() {
    echo -e "\n*******************************************************************\n"
}

create_user_and_groups() {
    # 建立组
    groupadd oinstall
    groupadd oper
    groupadd dba
    groupadd backupdba
    groupadd dgdba
    groupadd kmdba
    groupadd racdba

    # 建立用户
    useradd -g oinstall -G oper,dba,backupdba,dgdba,kmdba,racdba -p `openssl passwd -1 "oracle"` -d /home/oracle oracle 
    # echo "oracle" | passwd --stdin oracle
    echo "用户oracle已添加，密码为：oracle"
    add_comment
}

# 函数：确认操作
confirm_operation() {
    read -p "$1 (y/n): " choice
    if [[ ! $choice =~ ^[Yy]$ ]]; then
        echo "操作已取消。"
        exit 1
    fi
}

# 函数：创建安装目录并设置权限
# 参数：
#   $1: 是否选择了默认路径（true/false）
create_installation_directory_and_set_permissions() {
    local install_dir="$max_partition/data/app/oracle"

    # 创建目录

    if [ "$1" = true ]; then
        mkdir -p "$install_dir" || { echo "错误：无法创建目录 $install_dir" >&2; exit 1; }
        # 设置权限
        chmod 755 "$install_dir" || { echo "错误：无法设置目录权限 $install_dir" >&2; exit 1; }
        chown oracle.oinstall -R "$install_dir" || { echo "错误：无法设置目录所有者 $install_dir" >&2; exit 1; }
        echo "安装目录已创建，并设置了正确的权限。"        
        echo "用户选择了默认路径"
    else
        mkdir -p "$INSTALL_DIR" || { echo "错误：无法创建目录 $INSTALL_DIR" >&2; exit 1; }
        # 设置权限
        chmod 755 "$INSTALL_DIR" || { echo "错误：无法设置目录权限 $INSTALL_DIR" >&2; exit 1; }
        chown oracle.oinstall -R "$INSTALL_DIR" || { echo "错误：无法设置目录所有者 $INSTALL_DIR" >&2; exit 1; }
        echo "安装目录已创建，并设置了正确的权限。"        
        echo "用户未选择默认路径"
    fi
    mkdir -p $install_dir/../oraInventory
    chown -R oracle:oinstall  $install_dir/../oraInventory
    add_comment
}

# 函数：安装依赖包
install_dependencies() {
    echo "开始安装依赖包..."
    yum -y install binutils gcc unzip vim net-tools bc libnsl.x86_64 libaio libaio-devel  libXext libxcb libXi make sysstat gcc-c++  glibc glibc-devel ksh libgc  libstdc++ libstdc++-devel
    echo "依赖包安装完成。"
    add_comment
}

# 函数：设置SELinux
setup_selinux() {
    selinux=$(getenforce)
    if [ "$selinux" != "Disabled" ]; then
        confirm_operation "SELinux 将被禁用并需要重启。是否继续？"
        sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
        echo "SELinux 配置已修改，请重启计算机，并确保 SELinux 状态为 Disabled。"
        add_comment
        exit 0
    fi
    setenforce 
    firewall-cmd --zone=public --add-port=1521/tcp --permanent
    firewall-cmd --reload
    echo "SELinux 已关闭。"
    echo "防火墙已放行1521端口"
    add_comment
}

# 函数：设置主机名
setup_hostname() {
    new_hostname="oracledb"
    hostnamectl set-hostname "$new_hostname"
    echo "主机名已设置为 $new_hostname。"
    add_comment
}

# 函数：修改 /etc/hosts 文件
update_hosts_file() {
    localip=$(hostname -I)
    if grep -q "oracledb" /etc/hosts; then
        echo "主机文件已更新。"
    else
        echo "$localip    oracledb" | tee -a /etc/hosts
        echo "已更新主机文件。"
    fi
    add_comment
}

# 函数：重启网络服务
restart_network_service() {
    systemctl restart network
    echo "网络服务已重启。"
    add_comment
}

# 函数：解压安装包
extract_installation_packages() {
    local install_packages
    local package_dir
    local spinner="/|\\-"
    local delay=0.1

    # 查找安装包
    install_packages=($(find / -name "linuxamd64_12c_database_*" -o -name "V46095-01_*"))
    if [ ${#install_packages[@]} -eq 0 ]; then
        echo "错误：安装包不存在，请下载安装包。
        
        #https://updates.oracle.com/Orion/Services/download/p13390677_112040_Linux-x86-64_1of7.zip?aru=16716755&patch_file=p13390677_112040_Linux-x86-64_1of7.zip
        #https://updates.oracle.com/Orion/Services/download/p13390677_112040_Linux-x86-64_2of7.zip?aru=16716755&patch_file=p13390677_112040_Linux-x86-64_2of7.zip
        >&2
        exit 1
    fi

    package_dir=$(dirname "${install_packages[0]}")
    cd "$package_dir" || { echo "错误：无法进入目录 $package_dir" >&2; exit 1; }

    # 创建目录/software/database，如果不存在的话
    mkdir -p /software/database || { echo "错误：无法创建目录 /software/database" >&2; exit 1; }

    # 解压安装包到临时目录
    for package in "${install_packages[@]}"; do
        echo -n "正在解压安装包: $package "
        unzip -q "$package" -d /tmp && echo " 解压完成." || { echo " 解压失败." >&2; exit 1; }
    done

    # 查找并移动解压后的数据库目录到指定目录
    database_dirs=($(find /tmp -type d -name "database"))
    if [ ${#database_dirs[@]} -eq 0 ]; then
        echo "错误：找不到解压后的数据库目录。" >&2
        exit 1
    fi

    for db_dir in "${database_dirs[@]}"; do
        # 移动数据库目录下的内容到指定目录
        echo "正在移动数据库目录内容: $db_dir/* 到 /software/database"
        mv "$db_dir"/* /software/database || { echo "错误：移动数据库目录内容失败。" >&2; exit 1; }
        # 删除原始的数据库目录
        echo "正在删除原始数据库目录: $db_dir"
        rm -rf "$db_dir" || { echo "错误：删除数据库目录失败。" >&2; exit 1; }
    done

    echo "安装包已解压到 /software/database。"
    add_comment
}

add_ttc(){
    # 下载字体包
    echo "正在下载字体包..."
    # wget -O /tmp/wqy-zenhei.ttc https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/raw/main/wqy-zenhei.ttc

    # 进入文件夹目录
    cd /software/database/stage/Components/oracle.jdk/1.6.0.75.0/1/DataFiles/

    # 解压 filegroup2.jar
    unzip -o filegroup2.jar -d filegroup2_extracted >/dev/null 2>&1

    # 创建文件夹
    mkdir -p /software/database/stage/Components/oracle.jdk/1.6.0.75.0/1/DataFiles/filegroup2_extracted/jdk/jre/lib/fonts/fallback

# 查找 wqy-zenhei.ttc 字体包
FONT_PATH=$(find / -name wqy-zenhei.ttc 2>/dev/null)

# 检查是否找到字体包
if [ -z "$FONT_PATH" ]; then
    echo "未找到 wqy-zenhei.ttc 字体包，请确保字体包已正确安装。"
    exit 1
else
    echo "找到字体包: $FONT_PATH"
fi

# 目标目录
TARGET_DIR="/software/database/stage/Components/oracle.jdk/1.6.0.75.0/1/DataFiles/filegroup2_extracted/jdk/jre/lib/fonts/fallback/"

# 检查目标目录是否存在
if [ ! -d "$TARGET_DIR" ]; then
    echo "目标目录不存在: $TARGET_DIR"
    exit 1
else
    echo "目标目录存在: $TARGET_DIR"
fi

# 拷贝字体包到目标目录
cp "$FONT_PATH" "$TARGET_DIR"

# 检查是否成功拷贝
if [ $? -eq 0 ]; then
    echo "字体包已成功拷贝到目标目录。"
else
    echo "拷贝字体包时遇到错误。"
    exit 1
fi
    # 备份原文件
    mv /software/database/stage/Components/oracle.jdk/1.6.0.75.0/1/DataFiles/filegroup2.jar /software/database/stage/Components/oracle.jdk/1.6.0.75.0/1/DataFiles/filegroup2.jarbk

    # 重新打包 filegroup2.jar
    cd filegroup2_extracted
    sudo zip -r ../filegroup2.jar * >/dev/null 2>&1

    # 赋予文件权限
    sudo chmod 755 ../filegroup2.jar

    echo "filegroup2.jar 已重新打包并赋予适当权限。"
}


# 函数：设置系统参数
setup_system_parameters() {
    # 修改内核参数配置
    cp /etc/sysctl.conf /etc/sysctl.conf.bak
    shmall=$(echo "`cat /proc/meminfo | grep "MemTotal" | awk '{print $2}'` / (`getconf PAGESIZE` / 1024)" | bc)
    shmmax=$(echo "`cat /proc/meminfo | grep "MemTotal" | awk '{print $2}'` * 1024 * 0.8" | bc  | sed 's#\..*$##')
    if ! grep -q "net.ipv4.ip_local_port_range.*9000.*65500" /etc/sysctl.conf ||
        ! grep -q "fs.file-max.*6815744" /etc/sysctl.conf ||
        ! grep -q "kernel.shmall.*$shmall" /etc/sysctl.conf ||
        ! grep -q "kernel.shmmax.*$shmmax" /etc/sysctl.conf ||
        ! grep -q "kernel.shmmni.*4096" /etc/sysctl.conf ||
        ! grep -q "kernel.sem.*250.*32000.*100128" /etc/sysctl.conf ||
        ! grep -q "net.core.rmem_default.*262144" /etc/sysctl.conf ||
        ! grep -q "net.core.wmem_default.*262144" /etc/sysctl.conf ||
        ! grep -q "net.core.rmem_max.*4194304" /etc/sysctl.conf ||
        ! grep -q "net.core.wmem_max.*1048576" /etc/sysctl.conf ||
        ! grep -q "fs.aio-max-nr.*1048576" /etc/sysctl.conf; then
        cat <<EOF >>/etc/sysctl.conf
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = $shmall
kernel.shmmax = $shmmax
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
EOF
        echo "内核参数配置已修改。"
    else
        echo "内核参数配置已存在，无需修改。"
    fi
    sysctl -p

    # 修改系统资源限制
    cp /etc/security/limits.conf /etc/security/limits.conf.bak

    if ! grep -q "oracle.*nproc.*131072" /etc/security/limits.conf ||
        ! grep -q "oracle.*nofile.*131072" /etc/security/limits.conf ||
        ! grep -q "oracle.*stack.*10240" /etc/security/limits.conf ||
        ! grep -q "oracle.*memlock.*50000000" /etc/security/limits.conf; then
        cat <<EOF >>/etc/security/limits.conf
oracle   soft   nproc    131072
oracle   hard   nproc    131072
oracle   soft   nofile   131072
oracle   hard   nofile   131072
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   soft   memlock  50000000
oracle   hard   memlock  50000000
EOF
        echo "系统资源限制已修改。"
    else
        echo "系统资源限制已存在，无需修改。"
    fi

    # 修改用户验证选项
    cp /etc/pam.d/login /etc/pam.d/login.bak

    if ! grep -q "pam_limits.so" /etc/pam.d/login; then
        echo "session    required     pam_limits.so" >>/etc/pam.d/login
        echo "用户限制文件已修改。"
    else
        echo "用户限制文件已存在，无需修改。"
    fi
}

modify_response_file_content1() {
    local rsp_file="/software/database/response/db_install.rsp"
    cat << EOF > /software/database/response/db_install.rsp
oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=oracledb
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=/home/data/app/oracle/oraInventory
SELECTED_LANGUAGES=en,zh_CN
ORACLE_HOME=/home/data/app/oracle/product/12.1.0/dbhome_1
ORACLE_BASE=/home/data/app/oracle
oracle.install.db.InstallEdition=EE
oracle.install.db.DBA_GROUP=dba
oracle.install.db.OPER_GROUP=oper
oracle.install.db.BACKUPDBA_GROUP=backupdba
oracle.install.db.DGDBA_GROUP=dgdba
oracle.install.db.KMDBA_GROUP=kmdba
oracle.install.db.rac.configurationType=
oracle.install.db.CLUSTER_NODES=
oracle.install.db.isRACOneInstall=
oracle.install.db.racOneServiceName=
oracle.install.db.rac.serverpoolName=
oracle.install.db.rac.serverpoolCardinality=
oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
oracle.install.db.config.starterdb.globalDBName=orcl
oracle.install.db.config.starterdb.SID=orcl
oracle.install.db.ConfigureAsContainerDB=false
oracle.install.db.config.PDBName=
oracle.install.db.config.starterdb.characterSet=ZHS16GBK
oracle.install.db.config.starterdb.memoryOption=true
oracle.install.db.config.starterdb.memoryLimit=1500
oracle.install.db.config.starterdb.installExampleSchemas=false
oracle.install.db.config.starterdb.password.ALL=oracle
oracle.install.db.config.starterdb.password.SYS=
oracle.install.db.config.starterdb.password.SYSTEM=
oracle.install.db.config.starterdb.password.DBSNMP=
oracle.install.db.config.starterdb.password.PDBADMIN=
oracle.install.db.config.starterdb.managementOption=DEFAULT
oracle.install.db.config.starterdb.omsHost=
oracle.install.db.config.starterdb.omsPort=
oracle.install.db.config.starterdb.emAdminUser=
oracle.install.db.config.starterdb.emAdminPassword=
oracle.install.db.config.starterdb.enableRecovery=false
oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/home/data/app/oracle/oradata
oracle.install.db.config.starterdb.fileSystemStorage.recoveryLocation=
oracle.install.db.config.asm.diskGroup=
oracle.install.db.config.asm.ASMSNMPPassword=
MYORACLESUPPORT_USERNAME=
MYORACLESUPPORT_PASSWORD=
SECURITY_UPDATES_VIA_MYORACLESUPPORT=
DECLINE_SECURITY_UPDATES=true
PROXY_HOST=
PROXY_PORT=
PROXY_USER=
PROXY_PWD=
COLLECTOR_SUPPORTHUB_URL=
EOF
    echo "安装响应文件内容已修改。"
    add_comment
}

# 函数：修改安装响应文件的内容
# 参数：
#   $1: 是否选择了默认路径（true/false）

modify_response_file_content2() {
    local rsp_file="/software/database/response/db_install.rsp"
    local default_install_dir="$max_partition/data/app/oracle"

    if [ ! -f "$rsp_file" ]; then
        echo "错误：安装响应文件 $rsp_file 不存在。" >&2
        exit 1
    fi

    local use_default="$1"  # 获取参数

    # 替换安装响应文件中的内容
    if [ "$use_default" = true ]; then
        sed -i "s|^INVENTORY_LOCATION=.*$|INVENTORY_LOCATION=$default_install_dir/oraInventory|g" "$rsp_file"
        sed -i "s|^ORACLE_HOME=.*$|ORACLE_HOME=$default_install_dir/product/12.1.0/dbhome_1|g" "$rsp_file"
        sed -i "s|^ORACLE_BASE=.*$|ORACLE_BASE=$default_install_dir|g" "$rsp_file"
        echo "用户选择了默认路径"
    else
        sed -i "s|^INVENTORY_LOCATION=.*$|INVENTORY_LOCATION=$INSTALL_DIR/oraInventory|g" "$rsp_file"
        sed -i "s|^ORACLE_HOME=.*$|ORACLE_HOME=$INSTALL_DIR/product/12.1.0/dbhome_1|g" "$rsp_file"
        sed -i "s|^ORACLE_BASE=.*$|ORACLE_BASE=$INSTALL_DIR|g" "$rsp_file"
        echo "用户未选择默认路径"
    fi
    echo "dbinstall.rsp已修改"
    add_comment
}

modify_dbca_response_file() {
    local dbca_file="/software/database/response/dbca.rsp"
    cat << EOF > /software/database/response/dbca.rsp
[GENERAL]
RESPONSEFILE_VERSION = "/oracle/assistants/rspfmt_dbca_response_schema_v12.2.0"
OPERATION_TYPE = "createDatabase"
[CREATEDATABASE]
GDBNAME = "orcl"
DATABASECONFTYPE  = "SI"
SID = "orcl"
TEMPLATENAME = "General_Purpose.dbc"
SYSPASSWORD = "oracle"
SYSTEMPASSWORD = "oracle"
[createTemplateFromDB]
SOURCEDB = "myhost:1521:orcl"
SYSDBAUSERNAME = "system"
TEMPLATENAME = "My Copy TEMPLATE"
[createCloneTemplate]
SOURCEDB = "orcl"
TEMPLATENAME = "My Clone TEMPLATE"
[DELETEDATABASE]
SOURCEDB = "orcl"
[generateScripts]
TEMPLATENAME = "New Database"
GDBNAME = "orcl12.us.oracle.com"
[CONFIGUREDATABASE]
[ADDINSTANCE]
DB_UNIQUE_NAME = "orcl12c.us.oracle.com"
NODENAME=
SYSDBAUSERNAME = "sys"
[DELETEINSTANCE]
DB_UNIQUE_NAME = "orcl12c.us.oracle.com"
INSTANCENAME = "orcl12c"
SYSDBAUSERNAME = "sys"
[CREATEPLUGGABLEDATABASE]
SOURCEDB = "orcl"
PDBNAME = "PDB1"
[UNPLUGDATABASE]
SOURCEDB = "orcl"
PDBNAME = "PDB1"
ARCHIVETYPE = "TAR"
[DELETEPLUGGABLEDATABASE]
SOURCEDB = "orcl"
PDBNAME = "PDB1"
[CONFIGUREPLUGGABLEDATABASE]
SOURCEDB = "orcl"
PDBNAME = "PDB1"
EOF
    echo "dbca.rsp 文件已修改。"
}



#修改oracle用户的环境变量
modify_oracle_user_profile() {
    local use_default="$1"
    local bash_profile="/home/oracle/.bash_profile"
    
    # 注释掉.bash_profile文件中最后两行
    sed -i '/^export ORACLE_SID=/ s/^/#/' "$bash_profile"
    sed -i '/^export NLS_LANG=/ s/^/#/' "$bash_profile"
    
    # 决定$ORACLE_BASE的值
    local ORACLE_BASE
    if [ "$use_default" = true ]; then
        ORACLE_BASE="$max_partition/data/app/oracle"
    else
        ORACLE_BASE="$INSTALL_DIR"
    fi
    
    # 写入环境变量内容
    echo "export ORACLE_BASE=$ORACLE_BASE" >> "$bash_profile"
    echo "export ORACLE_HOME=\$ORACLE_BASE/product/12.1.0/dbhome_1" >> "$bash_profile"
    echo 'export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin' >> "$bash_profile"
    echo 'export ORACLE_SID=orcl' >> "$bash_profile"
    # echo 'export ORACLE_PID=ora11g' >> "$bash_profile"
    echo 'export NLS_LANG=AMERICAN_AMERICA.AL32UTF8' >> "$bash_profile"
    echo 'export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib' >> "$bash_profile"
    echo ".bash_profile文件已修改。"
}


install_oracle_database() {
    echo "开始安装 Oracle 数据库..."
    # 切换到 oracle 用户并执行安装
    su - oracle <<EOF
    cd /software/database/
    echo "开始安装："
    ./runInstaller -silent -responseFile /software/database/response/db_install.rsp -ignorePrereq
    echo "\n"
EOF
    echo "Oracle 数据库安装完成。"
}

check_installation_logs() {
    local log_dir="$INSTALL_DIR/oraInventory/logs"
    local success_flag=0
    local error_flag=0
    local spinner="|/-\-"
    local delay=5

    echo "开始检查安装日志文件..."

    # 循环检查安装日志文件
    while true; do
        for log_file in "$log_dir"/silentInstall*.log; do
            if grep -qE "成功|successful" "$log_file" >/dev/null 2>&1; then
                echo "安装成功。"
                execute_root_scripts
                success_flag=1
                break 2
            elif grep -qE "错误|error" "$log_file"; then
                sleep 10
                error_flag=1
                break
            fi
        done

        if [ $success_flag -eq 0 ] && [ $error_flag -eq 0 ]; then
            for (( i=0; i<${#spinner}; i++ )); do
                echo -ne "正在检查安装日志文件 ${spinner:$i:1}\r"
                sleep $delay
            done
        else
            break
        fi
    done

    if [ $success_flag -eq 0 ]; then
        if [ $error_flag -eq 1 ]; then
            echo "安装失败，请检查安装日志文件以获取详细信息。"
        else
            echo "未在任何安装日志文件中找到 '成功' 或 'successfully'，安装可能未成功。"
        fi
    fi
}

execute_root_scripts() {
    local oraInventory_root_script="$INSTALL_DIR/oraInventory/orainstRoot.sh"
    local oracle_root_script="$INSTALL_DIR/product/12.1.0/dbhome_1/root.sh"

    echo "以 root 用户的身份执行以下脚本："
    echo "1. $oraInventory_root_script"
    echo "2. $oracle_root_script"

    # 检查脚本文件是否存在，如果不存在则退出
    if [ ! -f "$oraInventory_root_script" ] || [ ! -f "$oracle_root_script" ]; then
        echo "错误：脚本文件不存在，请确保路径正确。"
        exit 1
    fi

    # 以 root 用户的身份执行脚本
    echo "执行 $oraInventory_root_script"
    sudo "$oraInventory_root_script"

    echo "执行 $oracle_root_script"
    sudo "$oracle_root_script"
}



# 函数：安装监听
install_netca() {
    echo "开始配置监听..."
    # 切换到 oracle 用户并执行安装
    su - oracle <<EOF
    \$ORACLE_HOME/bin/netca /silent /responseFile /software/database/response/netca.rsp
    echo "\n"
EOF
    echo "监听创建完成。"
    add_comment

}

# 函数：静默建库
install_dbca() {
    echo "开始建库..."
    # 切换到 oracle 用户并执行安装
    su - oracle <<EOF
    \$ORACLE_HOME/bin/dbca -silent -responseFile /software/database/response/dbca.rsp
EOF
    echo "静默建库已完成。"
    add_comment

}

ask_create_instance() {
    read -p "是否需要创建实例？(y/n): " create_instance
    if [[ $create_instance =~ ^[Yy]$ ]]; then
        install_dbca
        echo_db_info
    else
        echo "不创建实例。"
    fi
    add_comment
}


echo_server_info() {
    echo "服务器信息"
    add_comment
    echo "主机名：oracledb"
    echo "本机IP：$localip"
    echo "oracle用户密码：oracle"
    add_comment
}

echo_db_info() {
    echo "数据库信息"
    add_comment
    echo "GDBNAME：orcl"
    echo "SID:orcl"
    echo "PORT:1521"
    echo "sys用户密码：oracle"
    echo "system用户密码：oracle"
    echo "字符集：ZHS16GBK"
    add_comment
}

create_startup_sql(){
    cat  << EOF > /home/oracle/startup.sql
    conn / as sysdba
    startup
EOF

}

create_oracle_service(){
    cat << EOF > /etc/systemd/system/oracle.service
    [Unit]
    Description=Oracle Startup Service
    After=network.target

    [Service]
    Type=oneshot
    ExecStart=/bin/bash -lc 'su - oracle -c "lsnrctl start && sleep 10 && sqlplus /nolog @/home/oracle/startup.sql"'

    [Install]
    WantedBy=multi-user.target
EOF
}

auto_startup_oracle(){
    create_startup_sql
    create_oracle_service
    systemctl enable oracle
    echo "已添加开机自启"
    add_comment
}



# 主函数
main() {
    setup_selinux
    setup_hostname
    create_user_and_groups
    confirm_installation_path
    create_installation_directory_and_set_permissions
    update_hosts_file
    restart_network_service
    install_dependencies
    extract_installation_packages
    modify_response_file_content1
    modify_response_file_content2
    modify_dbca_response_file
    modify_oracle_user_profile
    add_ttc
    setup_system_parameters
    install_oracle_database
    check_installation_logs
    install_netca
    ask_create_instance
    auto_startup_oracle
    echo_server_info
    #echo_db_info
    echo "脚本执行完成。"
}

# 执行主函数
main
