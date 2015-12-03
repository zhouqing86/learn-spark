#!/bin/bash
DIR="$( cd "$( dirname "$0"  )" && pwd  )"
cd $DIR

if [ -z "$1" ]; then
    echo "usage: $0 [start|s|stop|p|ssh|c|reload|r|provision|v|status|st] [node1|node2|node3]"
    exit 1
fi

case $1 in
  "start" | "s")
    if [ -z "$2" ]; then
      foreman start -f Procfile.dev
    else
      cd $2 && vagrant up
    fi
    ;;
  "stop" | "halt" | "h")
    if [ -z "$2" ]; then
      foreman start -f halt.dev
    else
      cd $2 && vagrant halt
    fi
    ;;
  "reload" | "r")
      if [ -z "$2" ]; then
        foreman start -f reload.dev
      else
        cd $2 && vagrant reload
      fi
      ;;
  "provision" | "v")
      if [ -z "$2" ]; then
        foreman start -f provision.dev
      else
        cd $2 && vagrant provision
      fi
      ;;
  "status" | "st")
      if [ -z "$2" ]; then
        foreman start -f status.dev
      else
        cd $2 && vagrant status
      fi
      ;;
  "ssh" | "connect" | "c")
    if [ -z "$2" ]; then
      echo 'usage: ./op.sh ssh [node1|node2|node3]'
    else
      cd $2 && vagrant ssh
    fi
    ;;
esac
