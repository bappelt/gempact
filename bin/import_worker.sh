#!/bin/bash
set -ex
case "$1" in 
  start)
    echo "starting"
    cd /opt/gempact
    PIDFILE=/opt/gempact/shared/pids/resque_importer.pid BACKGROUND=yes QUEUE=importer_queue rake resque:work

    ;;
  stop)
    echo "stopping"
    /usr/local/bin/resque kill `hostname`:`cat /opt/gempact/shared/pids/resque_importer.pid`:importer_queue
    
    ;;
  *)
     echo "Invalid Input"
     exit 1
esac
