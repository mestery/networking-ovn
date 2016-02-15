#!/usr/bin/env bash
cp networking-ovn/devstack/db-local.conf.sample devstack/local.conf
if [ "$1" != "" ]; then
    sed -i -e 's/<IP address of host running everything else>/'$1'/g' devstack/local.conf
fi

# Get the IP address
ipaddress=$(ip -4 addr show eth1 | grep -oP "(?<=inet ).*(?=/)")

# Adjust some things in local.conf
cat << DEVSTACKEOF >> devstack/local.conf

# Set this to the address of the main DevStack host running the rest of the
# OpenStack services.
Q_HOST=$1
HOST_IP=$ipaddress
HOSTNAME=$(hostname)
DEVSTACKEOF

devstack/stack.sh

# NFS Server setup
sudo apt-get update
sudo apt-get install -y nfs-kernel-server nfs-common
sudo mkdir -p /opt/stack/data/nova/instances
sudo touch /etc/exports
sudo sh -c "echo \"/opt/stack/data/nova/instances 192.168.33.0/24(rw,sync,fsid=0,no_root_squash)\" >> /etc/exports"
sudo service nfs-kernel-server restart
sudo service idmapd restart
