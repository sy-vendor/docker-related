#!/bin/bash

# 等待 Elasticsearch 启动
echo "Waiting for Elasticsearch to start..."
until curl -s http://elasticsearch:9200 > /dev/null; do
    sleep 1
done

# 设置基本索引
curl -X PUT "elasticsearch:9200/logs" -H "Content-Type: application/json" -u elastic:admin -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "timestamp": {
        "type": "date"
      },
      "level": {
        "type": "keyword"
      },
      "message": {
        "type": "text"
      },
      "service": {
        "type": "keyword"
      }
    }
  }
}'

# 创建用户索引
curl -X PUT "elasticsearch:9200/users" -H "Content-Type: application/json" -u elastic:admin -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  },
  "mappings": {
    "properties": {
      "username": {
        "type": "keyword"
      },
      "email": {
        "type": "keyword"
      },
      "created_at": {
        "type": "date"
      },
      "updated_at": {
        "type": "date"
      }
    }
  }
}'

echo "Elasticsearch initialization completed!" 