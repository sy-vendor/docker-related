#!/bin/bash

# 等待 Jenkins 启动
echo "Waiting for Jenkins to start..."
until curl -s http://localhost:8080 > /dev/null; do
    sleep 1
done

# 获取 Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar

# 创建 Jenkins 用户
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "admin")' | java -jar jenkins-cli.jar -s http://localhost:8080/ groovy =

# 安装推荐的插件
java -jar jenkins-cli.jar -s http://localhost:8080/ install-plugin workflow-aggregator git docker-workflow pipeline-model-definition blueocean kubernetes kubernetes-cli prometheus metrics role-strategy credentials-binding ssh-agent ws-cleanup timestamper build-timeout ansicolor pipeline-utility-steps junit htmlpublisher email-ext slack

# 重启 Jenkins
java -jar jenkins-cli.jar -s http://localhost:8080/ safe-restart

echo "Jenkins initialization completed!" 