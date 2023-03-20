#!/bin/bash

# make by demo
# TODO
# 1. 优化系统配置、同步时间、安装必要的工具
# 2. 检查安装配置docker
# 3. 检查安装配置docker-compose
# 4. 构建必要的镜像
# 5. docker-compose 启动单机服务

set +e
set -o noglob

#
# Set Colors
#

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#
# Headers and Logging
#

underline() {
    printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() {
    printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() {
    printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() {
    printf "${white}%s${reset}\n" "$@"
}
info() {
    printf "${white}➜ %s${reset}\n" "$@"
}
success() {
    printf "${green}✔ %s${reset}\n" "$@"
}
error() {
    printf "${red}✖ %s${reset}\n" "$@"
}
warn() {
    printf "${tan}➜ %s${reset}\n" "$@"
}
bold() {
    printf "${bold}%s${reset}\n" "$@"
}
note() {
    printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}

set -e
set +o noglob

usage=$'请务必认真阅读README.md 文档.
在执行该脚本前务必确认文档中的配置已经修改正确，谢谢. 
please run this script with `--install`'
item=0

if [ "$1" != "--install" ]; then
    note "$usage"
    exit 1
fi

os_version=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`

h2 "[Step $item]: checking installation environment ..."
let item+=1

function before_start() {

    h2 "[Step $item]: install tools ..."
    let item+=1
    yum install -y net-tools vim lrzsz


    h2 "[Step $item]: optimize system ..."
    let item+=1
    source ./shell/optimize-os.sh

    h2 "[Step $item]: set time zone ..."
    let item+=1
    # 设置时区
    /bin/ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
    # 同步时间
    # ntpdate time.windows.com

    h2 "[Step $item]:  update turnserver configure ..."
    let item+=1
    # 修正turnserver 配置
    source ./shell/fix-turnserver-config.sh
    # 修正etcd配置文件IP
    source ./shell/fix-etcd.sh
}

function install_docker() {
    h2 "[Step $item]: docker is not installed, automatic installation begins ..."
    let item+=1
    if [ $os_version -eq '8' ]; then
      source ./shell/install-docker-8.sh
    elif [ $os_version -eq '7' ]; then
      source ./shell/install-docker-7.sh
    else
      error "only supports cento7.x and centos8.x"
      exit 1
    fi
    # im lincense 
    sh ./shell/fix-lincese.sh
}

function install_compose() {
    h2 "[Step $item]: dockercompose is not installed, automatic installation begins ..."
    let item+=1
    source ./shell/install-compose.sh
}

function build_docker_image() {
    h2 "[Step $item]: automatic build docker image begins ..."
    let item+=1
    source ./shell/build-image.sh
}

function init_data_dir() {
    h2 "[Step $item]: automatic init data dirs begins ..."
    let item+=1
    mkdir -p data/mongo data/mysql data/redis | echo "create data dirs success"
}

function init_by_compose() {
    h2 "[Step $item]: init servers begins ..."
    let item+=1
    docker-compose up -d
}

function check_docker() {
    if ! docker --version &>/dev/null; then
        install_docker
    fi

    # docker has been installed and check its version
    if [[ $(docker --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]; then
        docker_version=${BASH_REMATCH[1]}
        docker_version_part1=${BASH_REMATCH[2]}
        docker_version_part2=${BASH_REMATCH[3]}

        # the version of docker does not meet the requirement
        if [ "$docker_version_part1" -lt 17 ] || ([ "$docker_version_part1" -eq 17 ] && [ "$docker_version_part2" -lt 6 ]); then
            error "Need to upgrade docker package to 17.06.0+."
            exit 1
        else
            note "docker version: $docker_version"
        fi
    else
        error "Failed to parse docker version."
        exit 1
    fi
}

function check_dockercompose() {
    if ! docker-compose --version &>/dev/null; then
        install_compose
    fi

    # docker-compose has been installed, check its version
    if [[ $(docker-compose --version) =~ (([0-9]+).([0-9]+).([0-9]+)) ]]; then
        docker_compose_version=${BASH_REMATCH[1]}
        docker_compose_version_part1=${BASH_REMATCH[2]}
        docker_compose_version_part2=${BASH_REMATCH[3]}

        # the version of docker-compose does not meet the requirement
        if [ "$docker_compose_version_part1" -lt 1 ] || ([ "$docker_compose_version_part1" -eq 1 ] && [ "$docker_compose_version_part2" -lt 18 ]); then
            error "Need to upgrade docker-compose package to 1.18.0+."
            exit 1
        else
            note "docker-compose version: $docker_compose_version"
        fi
    else
        error "Failed to parse docker-compose version."
        exit 1
    fi
}

function make_auto_start() {
    h2 "[Step $item]: write boot script ..."
    let item+=1
    dir=$(pwd)
    if [ `grep -c "add by script end" /etc/rc.d/rc.local` -eq '0' ]; then
        echo "
# add by script start
cd $dir; docker-compose up -d
# add by script end 
        " >> /etc/rc.d/rc.local
        chmod a+x /etc/rc.d/rc.local
        h2 "[Step $item]: ready to reboot ..."
        let item+=1
        sleep 5
        reboot
    fi
}

before_start
init_data_dir
check_docker
check_dockercompose
build_docker_image
init_by_compose
make_auto_start
