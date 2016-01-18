#!/bin/bash

function provider_setup {
    sudo ovs-vsctl add-br br-provider
    
    sudo ovs-vsctl set open . external-ids:ovn-bridge-mappings=providernet:br-provider

    # Save the existing address from eth2
    PROVADDR=$(ifconfig eth2 | grep 192.168 | cut -d " " -f 12 | cut -d ":" -f 2)
    sudo ifconfig eth2 up 0.0.0.0 
    sudo ifconfig br-provider up $PROVADDR
    sudo ovs-vsctl add-port br-provider eth2
}
