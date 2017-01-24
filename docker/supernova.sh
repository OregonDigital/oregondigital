#!/usr/bin/env bash
#
# supernova.sh: when a nuke just isn't big enough.
#
# Builds upon nuke.sh to remove everything od-related, including the static
# oregondigital/* images in case of a local image build going wrong.
./docker/nuke.sh
csi=$(echo -e "\x1b[")
warn="${csi}31;1m"
info="${csi}34m"
reset="${csi}0m"
echo
echo -ne $warn
echo "Removing all images related to OregonDigital development"
echo -ne $reset
docker rmi $(docker images | grep "oregondigital" | awk '{print $3}')
echo
echo -ne $info
echo "Re-pulling / re-building will automatically happen next time you run"
echo "\`docker-compose up\`"
echo -ne $reset
