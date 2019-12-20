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

function build() {
    HOME_DIR=$(pwd)
    cd ../sites
    SITES_DIR=$(pwd)

    FOLDERS=$(ls -d */ | cut -f1 -d'/')

    HTTPD_FILE="$HOME_DIR/httpd/httpd.conf"
    NGINX_FILE="$HOME_DIR/nginx/nginx.conf"

    cat "$HTTPD_FILE.template" > $HTTPD_FILE
    cat "$NGINX_FILE.template" > $NGINX_FILE

    for dir in $(ls -d */ | cut -f1 -d'/'); do
        export SERVER_NAME="$dir.dev.loc"
        export SITE_DIR=$dir

        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/httpd/httpd.conf.vhost.template" >> $HTTPD_FILE
        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/nginx/nginx.conf.server.template" >> $NGINX_FILE
        echo "}" >> $NGINX_FILE
    done;
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
    build)
        build
        exit
    ;;
esac

show_help
