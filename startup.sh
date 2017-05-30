#!/bin/bash

echo "***** Checkout the flexswitch base image *******"
docker pull snapos/flex:latest

echo "***** Spawn 4 docker instances d_inst1 d_inst2 d_inst3 d_inst4"

docker run -dt --privileged --log-driver=syslog --cap-add=ALL  --name d_inst1   -P snapos/flex:latest
docker run -dt --privileged --log-driver=syslog --cap-add=ALL --name d_inst2 -P snapos/flex:latest
docker run -dt --privileged --log-driver=syslog --cap-add=ALL  --name d_inst3   -P snapos/flex:latest
docker run -dt --privileged --log-driver=syslog --cap-add=ALL  --name d_inst4   -P snapos/flex:latest

#sleep 5

d1_pid=`docker inspect -f '{{.State.Pid}}' d_inst1`
d2_pid=`docker inspect -f '{{.State.Pid}}' d_inst2`
d3_pid=`docker inspect -f '{{.State.Pid}}' d_inst3`
d4_pid=`docker inspect -f '{{.State.Pid}}' d_inst4`

sudo mkdir -p /var/run/netns

sudo ln -s /proc/$d1_pid/ns/net /var/run/netns/$d1_pid
sudo ln -s /proc/$d2_pid/ns/net /var/run/netns/$d2_pid
sudo ln -s /proc/$d3_pid/ns/net /var/run/netns/$d3_pid
sudo ln -s /proc/$d4_pid/ns/net /var/run/netns/$d4_pid

echo -e "done!\n"

sudo ip link add fpPort25 type veth peer name fpPort35
sudo ip link add fpPort45 type veth peer name fpPort55
sudo ip link add fpPort65 type veth peer name fpPort75


sudo ip link set fpPort25 netns $d1_pid
sudo ip netns exec $d1_pid ip link set fpPort25 up

sudo ip link set fpPort35 netns $d2_pid
sudo ip netns exec $d2_pid  ip link set fpPort35 up

sudo ip link set fpPort45 netns $d3_pid
sudo ip netns exec $d3_pid ip link set fpPort45 up

sudo ip link set fpPort55 netns $d4_pid
sudo ip netns exec $d4_pid ip link set fpPort55 up

sudo ip link set fpPort65 netns $d1_pid
sudo ip netns exec $d1_pid ip link set fpPort65 up

sudo ip link set fpPort75 netns $d4_pid
sudo ip netns exec $d4_pid ip link set fpPort75 up



echo -e "Preparing docker for the flexswtich . Please wait... "
sleep 5
echo -e "Start flexswtich to pick up the interfaces "
echo "##############################"
echo "#######d_inst1 FS restart######"
echo "##############################"
docker exec  d_inst1 sh -c "/etc/init.d/flexswitch restart"
echo "##############################"
echo "#######d_inst2 FS restart######"
echo "##############################"
docker exec d_inst2 sh -c "/etc/init.d/flexswitch restart"
echo -e "Start flexswtich to pick up the interfaces "
echo "##############################"
echo "#######d_inst3 FS restart######"
echo "##############################"
docker exec  d_inst3 sh -c "/etc/init.d/flexswitch restart"
echo -e "Start flexswtich to pick up the interfaces "
echo "##############################"
echo "#######d_inst4 FS restart######"
echo "##############################"
docker exec  d_inst4 sh -c "/etc/init.d/flexswitch restart"




















