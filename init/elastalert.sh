#!/bin/bash

PACKAGE=elastalert
PACKAGE_ROOT=/usr/share/${PACKAGE}-env
USERNAME=fk-supply-chain
#PIDFILE=/var/lib/$PACKAGE/fe-tracker.pid
#UWSGI_CONF=/etc/uwsgi/fe_tracker.ini

case "$1" in
  start)
    ulimit -n 10000
    cd /usr/share/${PACKAGE}
    sudo -u $USERNAME python -m elastalert.elastalert --verbose --rule /etc/elastalert/rule.yaml &>/home/fk-supply-chain/temp.log &
  ;;
  stop)
    kill -s SIGINT `pgrep -f elastalert`
  ;;
  force_kill)
    pkill -9 -f "elastalert"
  ;;
  restart)
    
    kill -s SIGINT `pgrep -f elastalert`
    sleep 20
    ulimit -n 10000
    sudo -u $USERNAME python -m elastalert.elastalert --verbose --rule /etc/elastalert/rule.yaml > /home/fk-supply-chain/temp.log & 
   ;;
  *)
    echo "USAGE: $0 start|stop"
    exit 3
  ;;
esac