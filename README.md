# docker-related

### 开始部署

下载代码到centos机器上，进入 docker 目录执行下面命令进行一键部署。

```
bash deploy.sh --install
```

### 服务管理

通常不需要对服务进行管理，如果有特殊需要请参考下列指南：

1. 检查服务状态

在改项目根目录执行 `docker-compose ps` 可以查看服务状态，`State` 栏为 `Up` 时代表服务正常
