# Anolis8.6GA（龙蜥8.6）安装oracle12c（12.1.0.2.0）
## 1. 开始安装
### 1.1 准备好安装包
V46095-01_1of2.zip
(https://edelivery.oracle.com/osdc/softwareDownload?fileName=V46095-01_1of2.zip&token=Mlo0Wmo3L2lyeFMrQmJUVk1wbGlMZyE6OiFmaWxlSWQ9NzIxNjI4ODEmZmlsZVNldENpZD04MjY4NzEmcmVsZWFzZUNpZHM9ODYxNzYmcGxhdGZvcm1DaWRzPTM1JmRvd25sb2FkVHlwZT05NTc2NCZhZ3JlZW1lbnRJZD0xMDgxNzk4OSZlbWFpbEFkZHJlc3M9emhhb3l1dGluZy0xMjNAb3V0bG9vay5jb20mdXNlck5hbWU9RVBELVpIQU9ZVVRJTkctMTIzQE9VVExPT0suQ09NJmNvdW50cnlDb2RlPUNOJmRscENpZHM9ODQyMTI5JnNlYXJjaFN0cmluZz1PcmFjbGUgRGF0YWJhc2UgMTJj)

V46095-01_2of2.zip
(https://edelivery.oracle.com/osdc/softwareDownload?fileName=V46095-01_2of2.zip&token=cWJRRU0vbmcvOHRlWGpwc0JHUmEydyE6OiFmaWxlSWQ9NzIxNjI4OTEmZmlsZVNldENpZD04MjY4NzEmcmVsZWFzZUNpZHM9ODYxNzYmcGxhdGZvcm1DaWRzPTM1JmRvd25sb2FkVHlwZT05NTc2NCZhZ3JlZW1lbnRJZD0xMDgxNzk4OSZlbWFpbEFkZHJlc3M9emhhb3l1dGluZy0xMjNAb3V0bG9vay5jb20mdXNlck5hbWU9RVBELVpIQU9ZVVRJTkctMTIzQE9VVExPT0suQ09NJmNvdW50cnlDb2RlPUNOJmRscENpZHM9ODQyMTI5JnNlYXJjaFN0cmluZz1PcmFjbGUgRGF0YWJhc2UgMTJj)
### 1.2 下载并执行安装脚本
```bash
curl -O https://raw.githubusercontent.com/Yogoshiteyo/Anolis8.6-install-oracle12c/main/oracle12c_install.sh && chmod +x oracle12c_install.sh && ./oracle12c_install.sh
```
## 2. 脚本所执行的操作
### 2.1 关闭selinux，使防火墙放行1521端口
```
usage:  setenforce [ Enforcing | Permissive | 1 | 0 ]
success
success
SELinux 已关闭。
防火墙已放行1521端口
```
### 2.2 更改主机名
```
主机名已设置为 oracledb。
```
### 2.3 建立用户和组
```
     oinstall
     oper
     dba
     backupdba
     dgdba
     kmdba
     racdba
    useradd -g oinstall -G oper,dba,backupdba,dgdba,kmdba,racdba -p `openssl passwd -1 "oracle"` -d /home/oracle oracle 

```
### 2.4 创建安装目录并设置权限
```
是否使用默认安装路径 (/home/data/app/oracle 在最大分区 /home 中)? (y/n): y
安装目录已创建，并设置了正确的权限。
用户未选择默认路径
```
### 2.5 修改host文件
```
192.168.3.68      oracledb
已更新主机文件。

```
### 2.6 安装依赖包
```
已升级:
  bc-1.07.1-5.0.1.an8.x86_64                                         binutils-2.30-123.0.1.an8.x86_64
  glibc-2.28-236.0.1.an8.12.x86_64                                   glibc-all-langpacks-2.28-236.0.1.an8.12.x86_64
  glibc-common-2.28-236.0.1.an8.12.x86_64                            glibc-gconv-extra-2.28-236.0.1.an8.12.x86_64
  glibc-langpack-en-2.28-236.0.1.an8.12.x86_64                       glibc-langpack-zh-2.28-236.0.1.an8.12.x86_64
  libXext-1.3.4-8.an8.x86_64                                         libaio-0.3.112-1.0.1.an8.x86_64
  libgcc-8.5.0-20.0.3.an8.x86_64                                     libgomp-8.5.0-20.0.3.an8.x86_64
  libstdc++-8.5.0-20.0.3.an8.x86_64                                  libxcrypt-4.1.1-6.0.3.an8.x86_64
  unzip-6.0-46.0.1.an8.x86_64                                        vim-common-2:8.0.1763-19.0.1.an8_6.4.x86_64
  vim-enhanced-2:8.0.1763-19.0.1.an8_6.4.x86_64
已安装:
  cpp-8.5.0-20.0.3.an8.x86_64                  gc-8.0.4-7.0.1.an8.x86_64                   gcc-8.5.0-20.0.3.an8.x86_64
  gcc-c++-8.5.0-20.0.3.an8.x86_64              glibc-devel-2.28-236.0.1.an8.12.x86_64      glibc-headers-2.28-236.0.1.an8.12.x86_64
  isl-0.16.1-6.0.1.an8.x86_64                  ksh-20120801-259.0.1.an8.x86_64             libaio-devel-0.3.112-1.0.1.an8.x86_64
  libasan-8.5.0-20.0.3.an8.x86_64              libatomic-8.5.0-20.0.3.an8.x86_64           libnsl-2.28-236.0.1.an8.12.x86_64
  libstdc++-devel-8.5.0-20.0.3.an8.x86_64      libubsan-8.5.0-20.0.3.an8.x86_64            libxcrypt-devel-4.1.1-6.0.3.an8.x86_64
  lm_sensors-libs-3.6.0-10.an8.x86_64          make-1:4.2.1-11.0.1.an8.x86_64              sysstat-11.7.3-11.0.1.an8.x86_64

完毕！
依赖包安装完成。

```
### 2.7 解压安装包
```
正在解压安装包: /root/V46095-01_1of2.zip  解压完成.
正在解压安装包: /root/V46095-01_2of2.zip  解压完成.
正在移动数据库目录内容: /tmp/database/* 到 /software/database
正在删除原始数据库目录: /tmp/database
安装包已解压到 /software/database。
```
### 2.8 修改内核参数及限制文件
```
内核参数配置已修改。
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 4028817
kernel.shmmax = 13201627545
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
```
### 2.9 修改环境变量
```
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
export ORACLE_BASE=/home/data/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.1.0/dbhome_1
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin
export ORACLE_SID=orcl
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
```
### 2.10 修改安装响应文件
```
*******************************************************************

安装响应文件内容已修改。

*******************************************************************

用户未选择默认路径
dbinstall.rsp已修改

*******************************************************************

dbca.rsp 文件已修改。

```
### 2.11 安装数据库软件
```
开始安装 Oracle 数据库...
开始安装：
正在启动 Oracle Universal Installer...

检查临时空间: 必须大于 500 MB。   实际为 73586 MB    通过
检查交换空间: 必须大于 150 MB。   实际为 16383 MB    通过
准备从以下地址启动 Oracle Universal Installer /tmp/OraInstall2024-05-30_03-15-55PM. 请稍候...\n
Oracle 数据库安装完成。
开始检查安装日志文件...
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
[WARNING] [INS-32055] 主产品清单位于 Oracle 基目录中。
   操作: Oracle 建议将此主产品清单放置在 Oracle 基目录之外的位置中。
可以在以下位置找到本次安装会话的日志:
 /home/data/app/oracle/oraInventory/logs/installActions2024-05-30_03-15-55PM.log
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
grep: /home/data/app/oracle/oraInventory/logs/silentInstall*.log: 没有那个文件或目录
Oracle Database 12c 的 安装 已成功。 志文件 -
请查看 '/home/data/app/oracle/oraInventory/logs/silentInstall2024-05-30_03-15-55PM.log' 以获取详细资料。

```
### 2.12 以 root 用户的身份执行以下脚本
```
Successfully Setup Software.
安装成功。
以 root 用户的身份执行以下脚本：
1. /home/data/app/oracle/oraInventory/orainstRoot.sh
2. /home/data/app/oracle/product/12.1.0/dbhome_1/root.sh
执行 /home/data/app/oracle/oraInventory/orainstRoot.sh
更改权限/home/data/app/oracle/oraInventory.
添加组的读取和写入权限。
删除全局的读取, 写入和执行权限。

更改组名/home/data/app/oracle/oraInventory 到 oinstall.
脚本的执行已完成。
执行 /home/data/app/oracle/product/12.1.0/dbhome_1/root.sh
Check /home/data/app/oracle/product/12.1.0/dbhome_1/install/root_oracledb_2024-05-30_15-18-53.log for the output of root script
```
### 2.13 开始配置监听
```
正在对命令行参数进行语法分析:
参数"silent" = true
参数"responsefile" = /software/database/response/netca.rsp
完成对命令行参数进行语法分析。
Oracle Net Services 配置:
完成概要文件配置。
Oracle Net 监听程序启动:
    正在运行监听程序控制:
      /home/data/app/oracle/product/12.1.0/dbhome_1/bin/lsnrctl start LISTENER
    监听程序控制完成。
    监听程序已成功启动。
监听程序配置完成。
成功完成 Oracle Net Services 配置。退出代码是0
\n
监听创建完成。

```
### 2.14 询问是否创建实例
```
是否需要创建实例？(y/n): y
开始建库...
复制数据库文件
1% 已完成
3% 已完成
11% 已完成
18% 已完成
26% 已完成
37% 已完成
正在创建并启动 Oracle 实例
40% 已完成
45% 已完成
50% 已完成
55% 已完成
56% 已完成
60% 已完成
62% 已完成
正在进行数据库创建
66% 已完成
70% 已完成
73% 已完成
85% 已完成
96% 已完成
100% 已完成
有关详细信息, 请参阅日志文件 "/home/data/app/oracle/cfgtoollogs/dbca/orcl/orcl.log"。
静默建库已完成。

```
### 2.15 添加开机自启
```
Created symlink /etc/systemd/system/multi-user.target.wants/oracle.service → /etc/systemd/system/oracle.service.
已添加开机自启
```
### 2.16 输出安装信息
```
*******************************************************************

服务器信息

*******************************************************************

主机名：oracledb
本机IP：192.168.3.68 192.168.122.1
oracle用户密码：oracle

*******************************************************************

数据库信息

*******************************************************************

GDBNAME：orcl
SID:orcl
PORT:1521
sys用户密码：oracle
system用户密码：oracle
字符集：ZHS16GBK

*******************************************************************
```
