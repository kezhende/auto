#!/bin/bash
apt-get update
apt-get install gcc python3-setuptools python3-pip python3.4-dev nginx -y
pip3 install uwsgi
pip3 install virtualenv

mkdir -p /etc/uwsgi/sites-enabled

cat uwsgi_rc > /etc/rc.local

read -p "reboot now?[y/n]" res 

if [ $res == 'y' ] || [ $res == 'Y' ]; then
    reboot
    return

fi

source uwsgi_rc

echo 'finish!'

