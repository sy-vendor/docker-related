# docker-related

这是一个基于 Docker 的微服务开发环境项目，集成了常用的中间件和工具，为开发团队提供一个完整的开发、测试环境。

## 项目组件

项目包含以下核心组件：

- **消息队列**：Kafka 集群（3个节点）和 Kafka Manager 管理界面
- **数据库**：
  - MySQL 5.7
  - MongoDB 3.4
  - Redis 5.0
- **搜索引擎**：
  - Elasticsearch 7.9.3
  - Kibana 7.9.3
- **服务发现与配置中心**：etcd 3.3.10
- **监控与追踪**：
  - Hystrix Dashboard：服务监控面板
  - Jaeger：分布式追踪系统
- **其他工具**：
  - ZooKeeper：用于 Kafka 集群协调
  - Nginx：反向代理服务器

## 端口说明

- Hystrix Dashboard: 8088
- Kafka: 9092-9094
- Kafka Manager: 9000
- MongoDB: 27017
- MySQL: 3306
- Redis: 6379
- etcd: 2379, 2380
- Jaeger: 16686 (UI), 5775, 6831, 6832 (UDP), 5778, 14268, 9411
- Elasticsearch: 9200, 9300
- Kibana: 5601

## 快速开始

### 环境要求
- Docker 19.03+
- Docker Compose 1.27+
- 至少 4GB 内存
- 至少 20GB 磁盘空间

### 开始部署

下载代码到centos机器上，进入 docker 目录执行下面命令进行一键部署。

```bash
bash deploy.sh --install
```

### 服务管理

通常不需要对服务进行管理，如果有特殊需要请参考下列指南：

1. 检查服务状态

在改项目根目录执行 `docker-compose ps` 可以查看服务状态，`State` 栏为 `Up` 时代表服务正常

### Elasticsearch 使用说明

1. 访问 Elasticsearch
   - REST API: http://localhost:9200
   - 默认用户名: elastic
   - 默认密码: admin

2. 访问 Kibana
   - Web界面: http://localhost:5601
   - 使用与 Elasticsearch 相同的凭据登录

3. 预配置的索引
   - logs: 用于日志存储
   - users: 用于用户数据存储

4. 性能优化
   - 已配置内存锁定
   - 优化了线程池设置
   - 启用了安全特性
