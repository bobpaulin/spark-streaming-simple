#!/bin/bash

DEBUG=0
BASEDIR=$(cd $(dirname $0); pwd)

NAMESERVER_IMAGE="amplab/dnsmasq-precise"

VOLUME_MAP=""

NUM_WORKERS=2

source $BASEDIR/start_nameserver.sh
source $BASEDIR/start_spark_cluster.sh

function check_root() {
    if [[ "$USER" != "root" ]]; then
        echo "please run as: sudo $0"
        exit 1
    fi
}

function print_help() {
    echo "usage: $0 [-w <#workers>] [-v <data_directory>] [-c]"
}

function parse_options() {
    while getopts "w:v:h" opt; do
        case $opt in
        w)
            NUM_WORKERS=$OPTARG
          ;;
        h)
            print_help
            exit 0
          ;;
        v)
            VOLUME_MAP=$OPTARG
          ;;
        esac
    done

    if [ ! "$VOLUME_MAP" == "" ]; then
        echo "data volume chosen: $VOLUME_MAP"
        VOLUME_MAP="-v $VOLUME_MAP:/data"
    fi
}

check_root

if [[ "$#" -eq 0 ]]; then
    print_help
    exit 1
fi

parse_options $@
SPARK_VERSION="1.1.0"
echo "*** Starting Spark $SPARK_VERSION ***"

start_nameserver $NAMESERVER_IMAGE
wait_for_nameserver
start_master
wait_for_master

start_workers
get_num_registered_workers
echo -n "waiting for workers to register "
until [[  "$NUM_REGISTERED_WORKERS" == "$NUM_WORKERS" ]]; do
    echo -n "."
    sleep 1
    get_num_registered_workers
done
echo ""
print_cluster_info
