#!/bin/bash

MASTER=-1
MASTER_IP=
NUM_REGISTERED_WORKERS=0
MASTER_IMAGE_NAME=bobpaulin/spark-streaming-simple-master
MASTER_IMAGE_VERSION=1.1.0
WORKER_IMAGE_NAME=bobpaulin/spark-streaming-simple-worker
WORKER_IMAGE_VERSION=1.1.0
# starts the Spark/Shark master container
function start_master() {
    echo "starting master container"
    if [ "$DEBUG" -gt 0 ]; then
        echo sudo docker run -d --dns $NAMESERVER_IP -p 8080:8080 -h master${DOMAINNAME} $VOLUME_MAP $MASTER_IMAGE_NAME:$MASTER_IMAGE_VERSION
    fi
    MASTER=$(sudo docker run -d --dns $NAMESERVER_IP -p 8080:8080 -h master${DOMAINNAME} $VOLUME_MAP $MASTER_IMAGE_NAME:$MASTER_IMAGE_VERSION)

    if [ "$MASTER" = "" ]; then
        echo "error: could not start master container from image $MASTER_IMAGE_NAME:$MASTER_IMAGE_VERSION"
        exit 1
    fi

    echo "started master container:      $MASTER"
    sleep 3
    MASTER_IP=$(sudo docker logs $MASTER 2>&1 | egrep '^MASTER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
    echo "MASTER_IP:                     $MASTER_IP"
    echo "address=\"/master/$MASTER_IP\"" >> $DNSFILE
}

# starts a number of Spark workers
function start_workers() {
    for i in `seq 1 $NUM_WORKERS`; do
        echo "starting worker container"
	hostname="worker${i}${DOMAINNAME}"
        if [ "$DEBUG" -gt 0 ]; then
	    echo sudo docker run -d --dns $NAMESERVER_IP -h $hostname $VOLUME_MAP $WORKER_IMAGE_NAME:$WORKER_IMAGE_VERSION ${MASTER_IP}
        fi
	WORKER=$(sudo docker run -d --dns $NAMESERVER_IP -h $hostname $VOLUME_MAP $WORKER_IMAGE_NAME:$WORKER_IMAGE_VERSION ${MASTER_IP})

        if [ "$WORKER" = "" ]; then
            echo "error: could not start worker container from image $WORKER_IMAGE_NAME:$WORKER_IMAGE_VERSION"
            exit 1
        fi

	echo "started worker container:  $WORKER"
	sleep 3
	WORKER_IP=$(sudo docker logs $WORKER 2>&1 | egrep '^WORKER_IP=' | awk -F= '{print $2}' | tr -d -c "[:digit:] .")
	echo "address=\"/$hostname/$WORKER_IP\"" >> $DNSFILE
    done
}

# prints out information on the cluster
function print_cluster_info() {
    BASEDIR=$(cd $(dirname $0); pwd)"/.."
    echo ""
    echo "***********************************************************************"
    #echo "start shell via:            $1"
    echo ""
    echo "visit Spark WebUI at:       http://$MASTER_IP:8080/"
    echo "ssh into master via:        ssh -i $BASEDIR/apache-hadoop-hdfs-precise/files/id_rsa -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@${MASTER_IP}"
    echo ""
    echo "/data mapped:               $VOLUME_MAP"
    echo ""
    echo "kill master via:           sudo docker kill $MASTER"
    echo "***********************************************************************"
    echo ""
    echo "to enable cluster name resolution add the following line to _the top_ of your host's /etc/resolv.conf:"
    echo "nameserver $NAMESERVER_IP"
}

function get_num_registered_workers() {

	# Docker on Mac uses tinycore Linux with busybox which has a limited version wget (?)
	echo $(uname -a) | grep "Linux boot2docker" > /dev/null
	if [[ "$?" == "0" ]]; then
		DATA=$( wget -Y off -q -O - http://$MASTER_IP:8080/json | tr -d '\n' | sed s/\"/\\\\\"/g)
	else
        	DATA=$( wget --no-proxy -q -O - http://$MASTER_IP:8080/json | tr -d '\n' | sed s/\"/\\\\\"/g)
	fi
    
    NUM_REGISTERED_WORKERS=$(python -c "import json; data = \"$DATA\"; value = json.loads(data); print len(value['workers'])")
}

function wait_for_master {
    
    query_string="MasterWebUI: Started MasterWebUI"
    
    echo -n "waiting for master "
    sudo docker logs $MASTER | grep "$query_string" > /dev/null
    until [ "$?" -eq 0 ]; do
        echo -n "."
        sleep 1
        sudo docker logs $MASTER | grep "$query_string" > /dev/null;
    done
    echo ""
    echo -n "waiting for nameserver to find master "
    check_hostname result master "$MASTER_IP"
    until [ "$result" -eq 0 ]; do
        echo -n "."
        sleep 1
        check_hostname result master "$MASTER_IP"
    done
    echo ""
    sleep 3
}
