#!/usr/bin/env bash
cp networking-ovn/devstack/computenode-local.conf.sample devstack/local.conf
if [ "$1" != "" ]; then
    sed -i -e 's/<IP address of host running everything else>/'$1'/g' devstack/local.conf
fi
if [ "$2" != "" ]; then
    ovnip=$2
fi

sudo umount /opt/stack/data/nova/instances

# Get the IP address
ipaddress=$(ip -4 addr show eth1 | grep -oP "(?<=inet ).*(?=/)")

# Fixup HOST_IP with the local IP address
sed -i -e 's/<IP address of current host>/'$ipaddress'/g' devstack/local.conf

# Adjust some things in local.conf
cat << DEVSTACKEOF >> devstack/local.conf

# Set this to the address of the main DevStack host running the rest of the
# OpenStack services.
Q_HOST=$1
HOSTNAME=$(hostname)
OVN_REMOTE=tcp:$ovnip:6640
enable_service q-dhcp q-meta
DEVSTACKEOF

# Add unique post-config for DevStack here using a separate 'cat' with
# single quotes around EOF to prevent interpretation of variables such
# as $Q_DHCP_CONF_FILE.

#cat << 'DEVSTACKEOF' >> devstack/local.conf

#[[post-config|/$ITEM]]
#DEVSTACKEOF

devstack/stack.sh

# Setup the provider network
source /vagrant/provisioning/provider-setup.sh

provider_setup

# Set the OVN_*_DB variables to enable OVN commands using a remote database.
echo -e "\n# Enable OVN commands using a remote database.
export OVN_NB_DB=$OVN_REMOTE
export OVN_SB_DB=$OVN_REMOTE" >> ~/.bash_profile

# NFS Setup
sudo mkdir -p /opt/stack/data/nova/instances
sudo chmod o+x /opt/stack/data/nova/instances
sudo chown vagrant:vagrant /opt/stack/data/nova/instances
sudo sh -c "echo \"192.168.33.11:/opt/stack/data/nova/instances /opt/stack/data/nova/instances nfs defaults 0 0\" >> /etc/fstab"
sudo mount /opt/stack/data/nova/instances
sudo sh -c "echo \"listen_tls = 0\" >> /etc/libvirt/libvirtd.conf"
sudo sh -c "echo \"listen_tcp = 1\" >> /etc/libvirt/libvirtd.conf"
sudo sh -c "echo -n \"auth_tcp =\" >> /etc/libvirt/libvirtd.conf"
sudo sh -c 'echo " \"none\"" >> /etc/libvirt/libvirtd.conf'
sudo sh -c "sed -i 's/env libvirtd_opts\=\"\-d\"/env libvirtd_opts\=\"-d -l\"/g' /etc/init/libvirt-bin.conf"
sudo sh -c "sed -i 's/libvirtd_opts\=\"\-d\"/libvirtd_opts\=\"\-d \-l\"/g' /etc/default/libvirt-bin"
sudo /etc/init.d/libvirt-bin restart
