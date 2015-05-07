#!/bin/bash
if [ $# != 1 ]; then
    echo "用法:source $0 [project] \n"
    return
fi

if [ $1 == 'finish' ]; then
    echo 'bye'
    rm -rf templates mo README.MD test.sh
    return
fi

if [ ! -d $1 ]; then
    echo "请输入正确的路径";return
fi

if [ -d $1'.virtualenv' ]; then
    echo '虚拟环境已创建，正在进入...'

else
    echo '开始创建虚拟环境...'
    virtualenv $1'.virtualenv'
    echo '虚拟环境创建成功,正在进入...'
fi

source $1'.virtualenv/bin/activate'

echo '进入项目...'
cd $1

if [ ! -f 'requirement.txt' ]; then
    echo '没有发现requirement.txt'
    return

fi

echo '正在安装所需软件包...'
pip3 install -r requirement.txt

echo '集合静态文件'
python3 manage.py collectstatic

echo '正在创建数据库...'
python3 manage.py migrate

echo '安装完毕，退出虚拟环境。'
deactivate

echo '退出项目'
cd ..

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
export DIR=$dir
export PROJECT=$1


echo '创建并链接uwsgi配置文件'
cat templates/uwsgi.tmp | ./mo  > "$1_uwsgi.ini"
ln -s "$1_uwsgi.ini" /etc/uwsgi/sites-enabled/


echo '创建并链接nginx配置文件'
read -p "输入配置的域名 : " domain
read -p "输入配置的端口 : " port

export PORT=$port
export DOMAIN=$domain

cat templates/nginx.tmp | ./mo  > "$1_nginx.conf"
ln -s "$dir/$1_nginx.conf" /etc/nginx/sites-enabled/

echo '重启uwsgi'
service uwsgi reload

echo '重启nginx'
service nginx restart
