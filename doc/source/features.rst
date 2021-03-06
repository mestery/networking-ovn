.. _features:

Features
========

Open Virtual Network (OVN) offers the following virtual network
services:

* Layer-2 (switching)

  Native implementation. Replaces the conventional Open vSwitch (OVS)
  agent.

* Layer-3 (routing)

  Native implementation or conventional layer-3 agent. The native
  implementation supports distributed routing. However, it currently lacks
  support for NAT.

* DHCP

  Currently uses conventional DHCP agent which supports availability zones.

* Metadata

  Currently uses conventional metadata agent.

* DPDK

  OVN and networking-ovn may be used with OVS using either the Linux kernel
  datapath or the DPDK datapath.

The following Neutron API extensions are supported with OVN:

+---------------------------+---------------------------+
| Extension Name            | Extension Alias           |
+===========================+===========================+
| agent                     | agent                     |
+---------------------------+---------------------------+
| Availability Zone         | availability_zone         |
+---------------------------+---------------------------+
| DHCP Agent Scheduler      | dhcp_agent_scheduler      |
+---------------------------+---------------------------+
| Network Availability Zone | network_availability_zone |
+---------------------------+---------------------------+
| Neutron external network  | external-net              |
+---------------------------+---------------------------+
| Neutron Extra DHCP opts   | extra_dhcp_opt            |
+---------------------------+---------------------------+
| Neutron Extra Route       | extraroute                |
+---------------------------+---------------------------+
| Neutron L3 Router         | router                    |
+---------------------------+---------------------------+
| Network MTU               | net-mtu                   |
+---------------------------+---------------------------+
| Port Binding              | binding                   |
+---------------------------+---------------------------+
| Provider Network          | provider                  |
+---------------------------+---------------------------+
| Quota management support  | quotas                    |
+---------------------------+---------------------------+
| RBAC Policies             | rbac-policies             |
+---------------------------+---------------------------+
| security-group            | security-group            |
+---------------------------+---------------------------+
| Subnet Allocation         | subnet_allocation         |
+---------------------------+---------------------------+
