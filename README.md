# Anolis8.6GA（龙蜥8.6）安装oracle12c（12.0.1.0.2）
## 1. 配置安装环境
### 1.1 下载脚本文件
### 1.2 为脚本赋予可执行权限
### 1.3 执行脚本
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
## 2. 开始安装oracle12c
### 2.1 进入图形界面，打开控制台
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/37cbab75-4ba3-48cc-98b4-36d9c696102b)
运行安装程序开始安装
```bash
/software/database/runInstaller
```
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/fdd7dd6c-39a4-4c70-9480-80e932bd1e50)

###2.2 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/1823d607-16a0-42ab-8e23-cc11a94dd6d3)

### 2.3 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/38fdc516-c972-42a1-8594-da480af18e86)

### 2.4 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/0b73fafe-1a82-44a3-aab5-0eb1d0fda19f)

### 2.5
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/cafa462f-fb6c-41d0-b5d8-22fb9b8ea704)

### 2.6 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/3f6dc125-bc78-43aa-aad1-e56eae5fcb22)

### 2.7 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/9b64066e-e3e4-4efc-bb47-2b23bfcc7a47)

### 2.8 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/a1e48ed0-dec2-458e-b108-8fc2dbdf71eb)

### 2.9 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/656f8d57-9e0f-411d-a981-fa9744b29060)

### 2.10 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/a8e25660-2203-43b1-b7d8-9a5f3456b19b)

### 2.11 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/43754572-3809-4185-9b3c-9e5c16bbef21)

### 2.12 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/c3057c19-3b8a-4b14-8055-2022d3dae240)

### 2.13 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/b9f68a70-1fc5-4471-98fc-7032b08f6652)

### 2.14 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/ae72d3d6-b6a7-42a1-8012-6d54ca3fcc07)

### 2.15 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/df4fc512-d374-4ddb-9a9c-71769b620137)
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/c9d9325d-1239-4d76-9c97-c6087c4d7f76)

### 2.16 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/d2efd655-f8d3-4c61-823d-cb3f60a04c82)

### 2.17














