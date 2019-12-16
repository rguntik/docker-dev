#!/usr/bin/env bash

cd $(dirname $0)
export CURRENT_UID=$(id -u):$(id -g)

function docker_up() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -f docker-compose.yml up $@
}

function docker_shutdown() {
  if [ -z ${VOLUME_DIR+x} ]; then
    echo "Do not run directly, run the toolbox.sh from your project folder"
    exit -1
  fi

  docker-compose -f docker-compose.yml down $@
}

function show_help() {
    printf "
Usage:
$ ./toolbox.sh COMMAND [COMMAND_ARGS...]

commands:
* up
* down
"
}

case "$1" in
up)
  shift
  docker_up $@
  exit
  ;;
down)
  shift
  docker_shutdown $@
  exit
  ;;
esac

show_help
