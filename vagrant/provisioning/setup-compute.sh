#!/usr/bin/env bash
cp networking-ovn/devstack/computenode-local.conf.sample devstack/local.conf
if [ "$1" != "" ]; then
    sed -i -e 's/<IP address of host running everything else>/'$1'/g' devstack/local.conf
fi
if [ "$2" != "" ]; then
    ovnip=$2
fi


# Get the IP address
ipaddress=$(/sbin/ifconfig eth1 | grep 'inet addr' | awk -F' ' '{print $2}' | awk -F':' '{print $2}')

# Adjust some things in local.conf
cat << DEVSTACKEOF >> devstack/local.conf

# Set this to the address of the main DevStack host running the rest of the
# OpenStack services.
Q_HOST=$1
HOST_IP=$ipaddress
HOSTNAME=$(hostname)
OVN_REMOTE=tcp:$ovnip:6640
DEVSTACKEOF

devstack/stack.sh

# Setup the provider network
source /vagrant/provisioning/provider-setup.sh

provider_setup
