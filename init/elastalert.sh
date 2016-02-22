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
    nohup python -m elastalert.elastalert --verbose --rule /etc/elastalert/rule.yaml &
  ;;
  stop)
   #kill -s SIGINT `cat $PIDFILE`
  ;;
  force_kill)
    #kill -9 `cat $PIDFILE`
  ;;
  restart)
    #kill -s SIGINT `cat $PIDFILE`
    sleep 20
    ulimit -n 10000
    #cd /var/lib/$PACKAGE
    #/usr/share/fk-ekl-fe-tracker-env/bin/uwsgi -H $PACKAGE_ROOT --pidfile $PIDFILE --ini $UWSGI_CONF
    ;;
  *)
    echo "USAGE: $0 start|stop"
    exit 3
  ;;
esac
