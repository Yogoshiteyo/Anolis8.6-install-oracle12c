# Anolis8.6GA（龙蜥8.6）安装oracle12c（12.1.0.2.0）
## 1. 配置安装环境
### 1.1 下载脚本文件
```bash
wget xxx && chmod +x && ./
```
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
### 2.1 登录oracle用户，进入图形界面，打开控制台
运行安装程序开始安装
```bash
/software/database/runInstaller
```
### 2.2 
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/9c06dbf4-9d67-4e4f-80f6-91b9e7823188)
### 2.3
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/cb2d3774-95b6-4beb-946c-9147c2fbfb30)
### 2.4
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/6bbe9069-f0b0-46b9-bd57-c7b8944e2737)
### 2.5
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/8652cba4-9c34-4f8a-a7c1-7f7dcf38cc1c)
### 2.6
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/a552891d-dfae-4c71-a112-d771a5078e18)
### 2.7
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/4bd161e6-e057-4974-993c-2184e9d8d0a2)
### 2.8
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/3430eaa2-2028-453d-bfa6-8dc9738ad57c)
### 2.9
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/c8a5736c-0b21-4af6-811a-97f45860b387)
### 2.10
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/38f78a04-cb0d-4568-a8de-1ece256ca978)
### 2.11
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/8100524f-e07d-49f3-851c-f6d59284aa59)
### 2.12
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/e452589a-a5c3-4de7-b7dd-55aa70321658)
### 2.13
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/006dbcdb-1f36-4185-abb8-7bd5907bea91)
### 2.14
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/b100f8e4-d878-4cc9-b4c9-bc363d41aef1)
### 2.15
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/b493e24d-fcf7-4b8f-951b-9a486a5d5b16)
### 2.16
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/77d236cf-6b67-4e1a-8ee7-78c26d30d09f)
### 2.17
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/ea54e3e8-0dc4-46cb-9a70-4e5cf5b8021b)
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/b7d297cd-b97f-41ca-923d-d6162760a1d1)
### 2.18
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/aa9078be-4ef1-4535-8b72-4a9fdebff605)
### 2.19
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/c7bcf2de-05a9-4b62-80c2-81ba9a11087c)
### 2.20
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/c9f1a960-00ca-42e0-ba90-f28baa293c21)
### 2.21
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/e6546b7e-867d-45e1-9de2-3ef8934b5d86)
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/e781963c-27ab-4901-8fd8-3bf96bf415b5)
### 2.22
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/f009bf0f-daa2-4213-9067-78a8ad46e0c2)
### 2.23
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/01c97bd3-5c6f-4f99-b198-b01e3815fcc0)
### 2.24
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/66e92a6f-8d6d-4020-9f19-6e6a88c1aabb)
### 2.25
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/7eafb8e1-2d0e-437c-95b6-6f44689a4192)
### 2.26
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/894f1c78-7a08-40c5-b0de-ab7a2e6d28de)
### 2.27
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/2c6a8f0c-2a2d-4948-8f55-8f7bf773cba0)
### 2.28
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/ce328100-8dbc-485a-b043-b972907c7f0c)
### 2.29
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/4e7f7c68-023f-42b1-b7bd-f49e75cd6485)
### 2.30
![image](https://github.com/Yogoshiteyo/Anolis8.6-install-oracle12c/assets/58699906/7003775b-659a-49e5-afc1-8afb4c80c44a)











