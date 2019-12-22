#!/usr/bin/env bash

export HOME_DIR=$(pwd)
cd ../sites
export VOLUME_DIR=$(pwd)
cd $HOME_DIR
export HOST_IP="172.123.0.1"

cd $(dirname $0)
export CURRENT_UID=$(id -u):$(id -g)

function build() {
    cd $VOLUME_DIR
    HTTPD_FILE="$HOME_DIR/httpd/httpd.conf"
    NGINX_FILE="$HOME_DIR/nginx/nginx.conf"

    cat "$HTTPD_FILE.template" > $HTTPD_FILE
    cat "$NGINX_FILE.template" > $NGINX_FILE

    cat /etc/hosts | grep -v $HOST_IP >"$HOME_DIR/hosts"
    echo "$HOST_IP dev.loc" >>"$HOME_DIR/hosts"

    for dir in $(ls -d */ | cut -f1 -d'/'); do
        export SERVER_NAME="$dir.dev.loc"
        export SITE_DIR=$dir

        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/httpd/httpd.conf.vhost.template" >> $HTTPD_FILE
        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/nginx/nginx.conf.server.template" >> $NGINX_FILE

        echo "$HOST_IP $SERVER_NAME" >>"$HOME_DIR/hosts"
    done;
    echo "}" >> $NGINX_FILE

    cat "$HOME_DIR/hosts" | sudo tee /etc/hosts
    echo "$HOST_IP dev.loc:8080" >>"$HOME_DIR/hosts"
    echo "<?php echo '" >"$VOLUME_DIR/index.php"
    cat "$HOME_DIR/hosts" | grep $HOST_IP | awk '{print "http://" $2 "<br>"}' >>"$VOLUME_DIR/index.php"
    echo "';" >>"$VOLUME_DIR/index.php"
    rm "$HOME_DIR/hosts"

}

function docker_up() {
    build
    cd $HOME_DIR
    docker-compose -f docker-compose.yml up $@
}

function docker_shutdown() {
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
    build)
        build
        exit
    ;;
esac

show_help
