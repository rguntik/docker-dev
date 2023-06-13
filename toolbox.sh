#!/usr/bin/env bash

export HOME_DIR=$(pwd)
cd ../sites
export VOLUME_DIR=$(pwd)
cd $HOME_DIR
export HOST_IP="172.123.0.1"
export NGINX_IP="172.123.0.11"
export LOCAL_IP=`hostname -I | cut -d' ' -f1`

cd $(dirname $0)
export CURRENT_UID=$(id -u):$(id -g)

# Export the vars in .env into your shell:
export $(egrep -v '^#' .env | xargs)

function build() {
    cd $VOLUME_DIR
    HTTPD_FILE="$HOME_DIR/httpd/httpd.conf"
    NGINX_FILE="$HOME_DIR/nginx/nginx.conf"

    cat "$HTTPD_FILE.template" > $HTTPD_FILE
    cat "$NGINX_FILE.template" > $NGINX_FILE

    cat /etc/hosts | grep -v $HOST_IP >"$HOME_DIR/hosts"
    echo "$HOST_IP dev.loc" >>"$HOME_DIR/hosts"

    for dir in $(ls -d */ | cut -f1 -d'/'); do
        if [ "$dir" == "public" ]; then
          continue
        fi
        export SERVER_NAME="$dir.dev.loc"
        export SITE_DIR=$dir

        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/httpd/httpd.conf.vhost.template" >> $HTTPD_FILE
        envsubst '${SERVER_NAME}, ${SITE_DIR}' <"$HOME_DIR/nginx/nginx.conf.server.template" >> $NGINX_FILE

        echo "$HOST_IP $SERVER_NAME" >>"$HOME_DIR/hosts"
    done;
    echo "}" >> $NGINX_FILE

    cat "$HOME_DIR/hosts" | sudo tee /etc/hosts
    echo "$HOST_IP dev.loc:8080" >>"$HOME_DIR/hosts"

    if [ ! -d "$VOLUME_DIR/public" ]; then
      mkdir "$VOLUME_DIR/public"
      echo "Directory created: $directory"
    fi

    cat "$HOME_DIR/hosts" | grep $HOST_IP | awk '{print "http://" $2}' >"$VOLUME_DIR/public/hostList.txt"
    rm "$HOME_DIR/hosts"
    rm "$VOLUME_DIR/public/index.php"
    cp "$HOME_DIR/index.php" "$VOLUME_DIR/public/index.php"
}

function docker_up() {
    cd $HOME_DIR
    docker-compose -f docker-compose.yml up $@
}

function docker_shutdown() {
    docker-compose -f docker-compose.yml down $@
}

function docker_compose() {
    docker-compose $@
}

function ssh() {
    docker exec -it home_dev_php bash
}

function xd() {
    DEBUG_PARAMS="
     -dxdebug.remote_enable=1\
     -dxdebug.remote_mode=req\
     -dxdebug.remote_port=9000\
     -dxdebug.remote_host=$LOCAL_IP\
     -dxdebug.remote_connect_back=0"

    docker exec  \
 -e="PHP_IDE_CONFIG=serverName=dev.local" -e="XDEBUG_CONFIG=idekey=PHPSTORM"  \
 home_dev_php php $DEBUG_PARAMS $@
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
    xd)
        shift
        xd $@
        exit
    ;;
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
    dc)
        shift
        docker_compose $@
        exit
    ;;
    ssh)
        ssh
        exit
    ;;
esac

show_help
