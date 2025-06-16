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

# 定义日志目录
LOG_DIR="logs"
LOG_ARCHIVE_DIR="$LOG_DIR/archive"
DATE=$(date +%Y%m%d_%H%M%S)

# 创建日志目录
create_log_dirs() {
    mkdir -p "$LOG_DIR"
    mkdir -p "$LOG_ARCHIVE_DIR"
    log_info "创建日志目录: $LOG_DIR 和 $LOG_ARCHIVE_DIR"
}

# 收集服务日志
collect_logs() {
    local service=$1
    log_info "开始收集 $service 的日志..."
    
    # 获取容器 ID
    local container_id=$(docker-compose ps -q $service)
    if [ -z "$container_id" ]; then
        log_error "$service 容器未运行"
        return 1
    fi
    
    # 收集日志
    docker-compose logs --tail=1000 $service > "$LOG_DIR/${service}_${DATE}.log"
    if [ $? -eq 0 ]; then
        log_info "$service 日志收集完成"
    else
        log_error "$service 日志收集失败"
    fi
}

# 收集所有服务日志
collect_all_logs() {
    log_info "开始收集所有服务日志..."
    
    # 收集基础服务日志
    collect_logs "mysql"
    collect_logs "mongodb"
    collect_logs "redis"
    
    # 收集消息队列日志
    collect_logs "kafka"
    collect_logs "rabbitmq"
    
    # 收集搜索引擎日志
    collect_logs "elasticsearch"
    collect_logs "kibana"
    
    # 收集监控系统日志
    collect_logs "prometheus"
    collect_logs "grafana"
    
    # 收集 CI/CD 日志
    collect_logs "jenkins"
    
    # 收集服务发现日志
    collect_logs "etcd"
    
    # 收集追踪系统日志
    collect_logs "jaeger"
}

# 压缩日志
compress_logs() {
    log_info "开始压缩日志..."
    tar -czf "$LOG_ARCHIVE_DIR/logs_${DATE}.tar.gz" -C "$LOG_DIR" .
    if [ $? -eq 0 ]; then
        log_info "日志压缩完成: $LOG_ARCHIVE_DIR/logs_${DATE}.tar.gz"
    else
        log_error "日志压缩失败"
    fi
}

# 清理旧日志
cleanup_old_logs() {
    local days=$1
    log_info "开始清理 $days 天前的日志..."
    
    # 清理日志文件
    find "$LOG_DIR" -type f -name "*.log" -mtime +$days -delete
    
    # 清理压缩文件
    find "$LOG_ARCHIVE_DIR" -type f -name "*.tar.gz" -mtime +$days -delete
    
    log_info "日志清理完成"
}

# 分析日志错误
analyze_log_errors() {
    local service=$1
    log_info "开始分析 $service 的日志错误..."
    
    # 检查日志文件是否存在
    local log_file="$LOG_DIR/${service}_${DATE}.log"
    if [ ! -f "$log_file" ]; then
        log_error "$service 日志文件不存在"
        return 1
    fi
    
    # 分析错误
    echo "=== $service 错误统计 ==="
    grep -i "error\|exception\|fail" "$log_file" | sort | uniq -c | sort -nr
    echo "========================"
}

# 分析所有服务日志错误
analyze_all_log_errors() {
    log_info "开始分析所有服务日志错误..."
    
    # 分析基础服务日志
    analyze_log_errors "mysql"
    analyze_log_errors "mongodb"
    analyze_log_errors "redis"
    
    # 分析消息队列日志
    analyze_log_errors "kafka"
    analyze_log_errors "rabbitmq"
    
    # 分析搜索引擎日志
    analyze_log_errors "elasticsearch"
    analyze_log_errors "kibana"
    
    # 分析监控系统日志
    analyze_log_errors "prometheus"
    analyze_log_errors "grafana"
    
    # 分析 CI/CD 日志
    analyze_log_errors "jenkins"
    
    # 分析服务发现日志
    analyze_log_errors "etcd"
    
    # 分析追踪系统日志
    analyze_log_errors "jaeger"
}

# 主函数
main() {
    create_log_dirs
    
    case "$1" in
        --collect)
            collect_all_logs
            compress_logs
            ;;
        --cleanup)
            if [ -z "$2" ]; then
                log_error "请指定保留天数"
                exit 1
            fi
            cleanup_old_logs "$2"
            ;;
        --analyze)
            analyze_all_log_errors
            ;;
        *)
            echo "用法: $0 {--collect|--cleanup <days>|--analyze}"
            exit 1
            ;;
    esac
}

main "$@" 