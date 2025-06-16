#!/bin/bash

# 定义颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 定义日志函数
log_info() {
    echo -e "${GREEN}[INFO] $1${NC}"
}

log_warn() {
    echo -e "${YELLOW}[WARN] $1${NC}"
}

log_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

# 检查服务状态
check_service_status() {
    local service=$1
    local status=$(docker-compose ps $service | grep $service | awk '{print $4}')
    
    if [ "$status" == "Up" ]; then
        log_info "$service 服务运行正常"
        return 0
    else
        log_error "$service 服务异常"
        return 1
    fi
}

# 检查服务端口
check_service_port() {
    local service=$1
    local port=$2
    
    if nc -z localhost $port >/dev/null 2>&1; then
        log_info "$service 端口 $port 可访问"
        return 0
    else
        log_error "$service 端口 $port 不可访问"
        return 1
    fi
}

# 检查服务日志
check_service_logs() {
    local service=$1
    local error_pattern=$2
    
    if docker-compose logs --tail=100 $service | grep -q "$error_pattern"; then
        log_error "$service 日志中发现错误: $error_pattern"
        return 1
    else
        log_info "$service 日志检查正常"
        return 0
    fi
}

# 检查服务资源使用
check_service_resources() {
    local service=$1
    local container_id=$(docker-compose ps -q $service)
    
    if [ -z "$container_id" ]; then
        log_error "$service 容器未运行"
        return 1
    fi
    
    # 检查 CPU 使用率
    local cpu_usage=$(docker stats --no-stream $container_id | awk 'NR>1 {print $3}' | sed 's/%//')
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        log_warn "$service CPU 使用率过高: $cpu_usage%"
    fi
    
    # 检查内存使用率
    local mem_usage=$(docker stats --no-stream $container_id | awk 'NR>1 {print $7}' | sed 's/%//')
    if (( $(echo "$mem_usage > 80" | bc -l) )); then
        log_warn "$service 内存使用率过高: $mem_usage%"
    fi
}

# 检查所有服务
check_all_services() {
    log_info "开始检查所有服务..."
    
    # 检查基础服务
    check_service_status "mysql"
    check_service_port "mysql" "3306"
    
    check_service_status "mongodb"
    check_service_port "mongodb" "27017"
    
    check_service_status "redis"
    check_service_port "redis" "6379"
    
    # 检查消息队列
    check_service_status "kafka"
    check_service_port "kafka" "9092"
    
    check_service_status "rabbitmq"
    check_service_port "rabbitmq" "5672"
    check_service_port "rabbitmq" "15672"
    
    # 检查搜索引擎
    check_service_status "elasticsearch"
    check_service_port "elasticsearch" "9200"
    
    check_service_status "kibana"
    check_service_port "kibana" "5601"
    
    # 检查监控系统
    check_service_status "prometheus"
    check_service_port "prometheus" "9090"
    
    check_service_status "grafana"
    check_service_port "grafana" "3000"
    
    # 检查 CI/CD
    check_service_status "jenkins"
    check_service_port "jenkins" "8080"
    
    # 检查服务发现
    check_service_status "etcd"
    check_service_port "etcd" "2379"
    
    # 检查追踪系统
    check_service_status "jaeger"
    check_service_port "jaeger" "16686"
}

# 检查服务资源使用情况
check_all_resources() {
    log_info "开始检查服务资源使用情况..."
    
    check_service_resources "mysql"
    check_service_resources "mongodb"
    check_service_resources "redis"
    check_service_resources "kafka"
    check_service_resources "rabbitmq"
    check_service_resources "elasticsearch"
    check_service_resources "prometheus"
    check_service_resources "grafana"
    check_service_resources "jenkins"
    check_service_resources "etcd"
    check_service_resources "jaeger"
}

# 检查服务日志
check_all_logs() {
    log_info "开始检查服务日志..."
    
    check_service_logs "mysql" "ERROR"
    check_service_logs "mongodb" "error"
    check_service_logs "redis" "error"
    check_service_logs "kafka" "ERROR"
    check_service_logs "rabbitmq" "error"
    check_service_logs "elasticsearch" "error"
    check_service_logs "prometheus" "error"
    check_service_logs "grafana" "error"
    check_service_logs "jenkins" "ERROR"
    check_service_logs "etcd" "error"
    check_service_logs "jaeger" "error"
}

# 主函数
main() {
    log_info "开始健康检查..."
    
    # 检查所有服务状态
    check_all_services
    
    # 检查服务资源使用情况
    check_all_resources
    
    # 检查服务日志
    check_all_logs
    
    log_info "健康检查完成"
}

# 解析命令行参数
case "$1" in
    --all)
        main
        ;;
    --status)
        check_all_services
        ;;
    --resources)
        check_all_resources
        ;;
    --logs)
        check_all_logs
        ;;
    *)
        echo "用法: $0 {--all|--status|--resources|--logs}"
        exit 1
        ;;
esac

exit 0 