#!/bin/bash

MANAGER_IP=$1
NODE_IP=$2
SHARED_FOLDER=/home/core/share
TOKEN=

# check shared folder exsits
if [ ! -d "$SHARED_FOLDER" ]; then
	echo ERROR: $SHARED_FOLDER does not exists.
    exit 1 # terminate and indicate error
fi

# check if docker is running
if [ "`systemctl is-active docker-tls-tcp.socket`" != "active" ]; then
	echo ERROR: 'docker-tls-tcp.socket' is not running.
    exit 1 # terminate and indicate error
fi

# set token
TOKEN=`cat ${SHARED_FOLDER}/worker_token`

# join swarm
docker swarm join --listen-addr ${NODE_IP}:2377 --advertise-addr ${NODE_IP} --token=$TOKEN ${MANAGER_IP}:2377
