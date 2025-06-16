# docker-related

这是一个基于 Docker 的微服务开发环境项目，集成了常用的中间件和工具，为开发团队提供一个完整的开发、测试环境。

## 项目组件

项目包含以下核心组件：

- **消息队列**：
  - Kafka 集群（3个节点）和 Kafka Manager 管理界面
  - RabbitMQ 集群（3个节点）和 Management 管理界面
- **数据库**：
  - MySQL 5.7
  - MongoDB 3.4
  - Redis 5.0
- **搜索引擎**：
  - Elasticsearch 7.9.3
  - Kibana 7.9.3
- **监控系统**：
  - Prometheus：指标收集和告警
  - Grafana：可视化监控面板
  - AlertManager：告警管理
  - Node Exporter：主机监控
  - cAdvisor：容器监控
- **CI/CD**：
  - Jenkins：持续集成和部署
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
- RabbitMQ: 5672-5674
- RabbitMQ Management: 15672-15674
- MongoDB: 27017
- MySQL: 3306
- Redis: 6379
- etcd: 2379, 2380
- Jaeger: 16686 (UI), 5775, 6831, 6832 (UDP), 5778, 14268, 9411
- Elasticsearch: 9200, 9300
- Kibana: 5601
- Prometheus: 9090
- AlertManager: 9093
- Grafana: 3000
- Node Exporter: 9100
- cAdvisor: 8080
- MySQL Exporter: 9104
- Redis Exporter: 9121
- MongoDB Exporter: 9216
- Jenkins: 8080
- Jenkins Agent: 50000

## 脚本说明

项目包含以下管理脚本：

### 1. 部署脚本 (deploy.sh)

用于部署和管理整个开发环境。

```bash
# 安装服务
./deploy.sh --install

# 卸载服务
./deploy.sh --uninstall

# 重启服务
./deploy.sh --restart

# 查看服务状态
./deploy.sh --status
```

### 2. 健康检查脚本 (scripts/health_check.sh)

用于检查各个服务的健康状态。

```bash
# 检查所有服务
./scripts/health_check.sh --all

# 只检查服务状态
./scripts/health_check.sh --status

# 只检查资源使用情况
./scripts/health_check.sh --resources

# 只检查服务日志
./scripts/health_check.sh --logs
```

### 3. 备份和恢复脚本 (scripts/backup.sh)

用于备份和恢复各个服务的数据。

```bash
# 备份所有服务数据
./scripts/backup.sh --backup

# 从备份文件恢复
./scripts/backup.sh --restore <backup_file>
```

### 4. 日志管理脚本 (scripts/log_manage.sh)

用于收集、分析和清理服务日志。

```bash
# 收集所有服务日志
./scripts/log_manage.sh --collect

# 清理指定天数前的日志
./scripts/log_manage.sh --cleanup <days>

# 分析所有服务日志错误
./scripts/log_manage.sh --analyze
```

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

### Jenkins 使用说明

1. 访问 Jenkins
   - Web界面: http://localhost:8080
   - 默认用户名: admin
   - 默认密码: admin

2. 预配置的插件
   - Pipeline：流水线支持
   - Git：版本控制
   - Docker：容器支持
   - Kubernetes：容器编排
   - Prometheus：监控集成
   - Blue Ocean：流水线可视化
   - 其他实用插件

3. 预配置的流水线
   - build-and-deploy：构建和部署流水线
   - 包含以下阶段：
     - Checkout：检出代码
     - Build：构建镜像
     - Test：运行测试
     - Deploy：部署服务

4. 安全配置
   - 基于角色的访问控制
   - 预配置用户角色：
     - admin：管理员权限
     - developer：开发者权限

5. 集成功能
   - Docker 构建支持
   - Git 仓库集成
   - 邮件通知
   - Slack 通知
   - 测试报告
   - 构建历史

### 监控系统使用说明

1. 访问 Grafana
   - Web界面: http://localhost:3000
   - 默认用户名: admin
   - 默认密码: admin

2. 访问 Prometheus
   - Web界面: http://localhost:9090
   - 查询界面: http://localhost:9090/graph

3. 访问 AlertManager
   - Web界面: http://localhost:9093

4. 预配置的监控项
   - 主机监控：CPU、内存、磁盘使用率
   - 容器监控：资源使用、性能指标
   - 服务监控：MySQL、Redis、MongoDB、Elasticsearch、RabbitMQ
   - 应用监控：HTTP 请求延迟、错误率

5. 告警规则
   - CPU 使用率超过 80%
   - 内存使用率超过 85%
   - 磁盘使用率超过 85%
   - 服务不可用超过 1 分钟
   - HTTP 请求延迟超过 1 秒

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
