# Openstack-Kolla-Ansible Deployment

### Official documentation of Openstack-kolla-ansible
[Openstack-kolla-ansible official docs](https://docs.openstack.org/kolla-ansible/latest/user/quickstart.html#install-kolla-ansible)

---
### A video guide for deploying openstack-kolla-ansible
[Video for deploying openstack-kolla-ansible](https://www.youtube.com/watch?v=b-XgSPuedro&list=LL&index=1)
[My self guide video for beginners](https://youtu.be/AwFv0DWA8Qc) 
---

### Official documnetation of openstack/kolla-ansible repository
[Openstack/kolla-ansible official repo](https://opendev.org/openstack/kolla-ansible)

---

*Quickstart*

**This guide provides instructions to deploy OpenStack using Kolla Ansible on bare metal servers or virtual machines.**

*Recommended Reading*

**It’s beneficial to learn basics of both [Ansible](https://docs.ansible.com/) and [Docker](https://docs.docker.com/) before running Kolla Ansible.**

### ***Host machine requirements***

The host machine must satisfy the following minimum requirements:

- 2 network interfaces

- 8GB main memory

- 40GB disk space

---
## Openstack Login

*After Entering the ip that you provide in /etc/kolla/gobal.yml that is your eth0 ip in your browser you will see a window like below this*


![](https://i.ytimg.com/vi/ZpjNS1p3kAQ/maxresdefault.jpg)

##### Your Default username is: ***admin***
##### For password, `cat /etc/kolla/passwords.yml | grep keystone_admin_password` and it will give you password to login.

---
## Host Network Bridge Information:

OpenStack-Ansible uses bridges to connect physical and logical network interfaces on the host to virtual network interfaces within containers. Target hosts need to be configured with the following network bridges:

![](https://lh3.googleusercontent.com/GEEKQiewwupz56eTi9u6mcfwiglmTqCQJM0yITAntcBRuXQ-SQVgH5cndtsYo60kKiLjlcik6DzVJEJNRS_HeGrMxa26JsWui9B1ydhPWHivCc5sGQ2WAOUcSvL0seq9CdiQLiFQ9nGOops0p2k)

  

-   LXC internal: lxcbr0  
      
    The lxcbr0 bridge is required for LXC, but OpenStack-Ansible configures it automatically. It provides external (typically Internet) connectivity to containers with dnsmasq (DHCP/DNS) + NAT.  
      
    This bridge does not directly attach to any physical or logical interfaces on the host because iptables handles connectivity. It attaches to eth0 in each container.  
      
    The container network that the bridge attaches to is configurable in the openstack_user_config.yml file in the provider_networks dictionary.  
      
    
-   Container management: br-mgmt  
      
    The br-mgmt bridge provides management of and communication between the infrastructure and OpenStack services.  
      
    The bridge attaches to a physical or logical interface, typically a bond0 VLAN subinterface. It also attaches to eth1 in each container.  
      
    The container network interface that the bridge attaches to is configurable in the openstack_user_config.yml file.  
      
    
-   Storage:br-storage  
      
    The br-storage bridge provides segregated access to Block Storage devices between OpenStack services and Block Storage devices.  
      
    The bridge attaches to a physical or logical interface, typically a bond0 VLAN subinterface. It also attaches to eth2 in each associated container.  
      
    The container network interface that the bridge attaches to is configurable in the openstack_user_config.yml file.  
      
    
-   OpenStack Networking tunnel: br-vxlan  
      
    The br-vxlan interface is required if the environment is configured to allow projects to create virtual networks using VXLAN. It provides the interface for encapsulated virtual (VXLAN) tunnel network traffic.  
      
    Note that br-vxlan is not required to be a bridge at all, a physical interface or a bond VLAN subinterface can be used directly and will be more efficient. The name br-vxlan is maintained here for consistency in the documentation and example configurations.  
      
    The container network interface it attaches to is configurable in the openstack_user_config.yml file.  
      
    
-   OpenStack Networking provider: br-vlan  
      
    The br-vlan bridge provides infrastructure for VLAN tagged or flat (no VLAN tag) networks.  
      
    The bridge attaches to a physical or logical interface, typically bond1. It is not assigned an IP address because it handles only layer 2 connectivity.  
      
    The container network interface that the bridge attaches to is configurable in the openstack_user_config.yml file.

---

## Storage Configuration:
LVM: Local volume manager

Logical volume management (LVM) is a form of storage virtualization that offers system administrators a more flexible approach to managing disk storage space than traditional partitioning.

