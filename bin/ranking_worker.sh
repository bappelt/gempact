#!/bin/bash
set -ex
case "$1" in 
  start)
    echo "starting"
    cd /opt/gempact
    PIDFILE=/opt/gempact/shared/pids/resque_ranking.pid BACKGROUND=yes QUEUE=ranking_queue rake resque:work

    ;;
  stop)
    echo "stopping"
    /usr/local/bin/resque kill `hostname`:`cat /opt/gempact/shared/pids/resque_ranking.pid`:ranking_queue 
    
    ;;
  *)
     echo "Invalid Input"
     exit 1
esac
