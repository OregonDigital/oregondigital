#!/usr/bin/env bash
#
# Forcibly destroys all OD docker containers and volumes
docker stop $(docker ps -qaf "name=oregondigital*")
docker stop $(docker ps -qaf "name=odtest*")
docker rm -f $(docker ps -qaf "name=oregondigital*")
docker rm -f $(docker ps -qaf "name=odtest*")
docker volume rm $(docker volume ls -qf "name=oregondigital*")
docker rmi oregondigital/od1-dev
docker rmi oregondigital/od1-test
