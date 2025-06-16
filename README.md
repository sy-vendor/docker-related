# docker-related

这是一个基于 Docker 的微服务开发环境项目，集成了常用的中间件和工具，为开发团队提供一个完整的开发、测试环境。

## 项目组件

项目包含以下核心组件：

- **消息队列**：Kafka 集群（3个节点）和 Kafka Manager 管理界面
- **数据库**：
  - MySQL 5.7
  - MongoDB 3.4
  - Redis 5.0
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

### 开始部署

下载代码到centos机器上，进入 docker 目录执行下面命令进行一键部署。

```