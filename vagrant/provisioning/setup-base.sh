#!/bin/sh

MTU=1500

if [ "$1" != "" ]; then
    MTU=$1
fi

DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy git
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy bridge-utils
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy ebtables
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy python-pip
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy python-dev
DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy build-essential
echo export LC_ALL=en_US.UTF-8 >> ~/.bash_profile
echo export LANG=en_US.UTF-8 >> ~/.bash_profile
# FIXME(mestery): Remove once Vagrant boxes allow apt-get to work again
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get install -y git

# FIXME(mestery): By default, Ubuntu ships with /bin/sh pointing to
# the dash shell.
# ..
# ..
# The dots above represent a pause as you pick yourself up off the
# floor. This means the latest version of "install_docker.sh" to load
# docker fails because dash can't interpret some of it's bash-specific
# things. It's a bug in install_docker.sh that it relies on those and
# uses a shebang of /bin/sh, but that doesn't help us if we want to run
# docker and specifically Kuryr. So, this works around that.
sudo update-alternatives --install /bin/sh sh /bin/bash 100

if [ ! -d "devstack" ]; then
    git clone https://git.openstack.org/openstack-dev/devstack.git
fi

# If available, use repositories on host to facilitate testing local changes.
# Vagrant requires that shared folders exist on the host, so additionally
# check for the ".git" directory in case the parent exists but lacks
# repository contents.

if [ ! -d "networking-ovn/.git" ]; then
    git clone https://git.openstack.org/openstack/networking-ovn.git
fi

# We need swap space to do any sort of scale testing with the Vagrant config.
# Without this, we quickly run out of RAM and the kernel starts whacking things.
sudo rm -f /swapfile1
sudo dd if=/dev/zero of=/swapfile1 bs=1024 count=8388608
sudo chown root:root /swapfile1
sudo chmod 0600 /swapfile1
sudo mkswap /swapfile1
sudo swapon /swapfile1

# Configure MTU on VM interfaces. Also requires manually configuring the same MTU on
# the equivalent 'vboxnet' interfaces on the host.
sudo ip link set dev eth1 mtu $MTU
sudo ip link set dev eth2 mtu $MTU

# Migration setup
sudo sh -c "echo \"192.168.33.11 ovn-db\" >> /etc/hosts"
sudo sh -c "echo \"192.168.33.12 ovn-controller\" >> /etc/hosts"
sudo sh -c "echo \"192.168.33.31 ovn-compute1\" >> /etc/hosts"
sudo sh -c "echo \"192.168.33.32 ovn-compute2\" >> /etc/hosts"

# Passwordless ssh setup
wget "https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant"
mv vagrant .ssh/id_rsa
chmod 600 .ssh/id_rsa
sudo cp ~vagrant/.ssh/id_rsa ~/.ssh
