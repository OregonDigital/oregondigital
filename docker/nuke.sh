#!/usr/bin/env bash
#
# Forcibly destroys all OD docker containers and volumes
csi=$(echo -e "\x1b[")
warn="${csi}31;1m"
info="${csi}34m"
reset="${csi}0m"
echo -ne $warn
echo "Stopping and removing all containers related to OregonDigital development"
echo -ne $reset$info
echo "(Ignore any errors that occur, as docker is very verbose when you try to"
echo "stop or remove anything already stopped/removed)"
echo -ne $reset
docker stop $(docker ps -qaf "name=oregondigital*")
docker stop $(docker ps -qaf "name=odtest*")
docker rm -f $(docker ps -qaf "name=oregondigital*")
docker rm -f $(docker ps -qaf "name=odtest*")
docker volume rm $(docker volume ls -qf "name=oregondigital*")
docker rmi oregondigital/od1-dev
docker rmi oregondigital/od1-test
