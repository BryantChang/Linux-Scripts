# Linux脚本小工具合集

## 简介

```
本项目是自己日常学习工作过程中的一些常用脚本，主要关于大数据平台的部署与运维，
包括SSH配置，Mysql安装，Spark，Hadoop等平台的启停操作等
```

## 目录结构

```
-Linux-tools
    --Platform_scripts
        --Hadoop(Hadoop平台的相关操作)
        --Spark(Spark平台操作)
    --System_scripts
        --iostat(磁盘带宽统计)
        --mysql(全自动安装mysql)
        --ssh(SSH相关操作)
            --auto_ssh.sh(一键免密通信)
            --mscp.sh(文件分发)
            --passwd_config(节点配置文件，包括主机名，密码等)
            --ssh_cmd.sh(多机执行命令)
```

* 每个脚本的使用方法在各个脚本中都有详细介绍，这里不赘述，希望能够对大家有帮助