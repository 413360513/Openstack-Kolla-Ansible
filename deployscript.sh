#Install dependencies

sudo apt update
yes | sudo apt install python3-dev libffi-dev gcc libssl-dev


#Install dependencies of Not using a virtual Environment

yes | sudo apt install python3-pip
sudo pip3 install -U pip
sudo pip install -U 'ansible>=4,<6'

#Install Kolla-ansible

sudo pip3 install git+https://opendev.org/openstack/kolla-ansible@master
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* .

#Install Ansible Galaxy requirements

kolla-ansible install-deps

#Configure Ansible

mkdir /etc/ansible
tee /etc/ansible/ansible.cfg<<EOF
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

#Configuring Kolla globals.yaml

sudo apt install net-tools

#We are storing the ip of eth0 for further or future use.
my_br_ip=$(ifconfig eth0 | egrep -o 'inet [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'  | cut -d' ' -f2)

#Install kolla For Deployment

git clone --branch master https://opendev.org/openstack/kolla-ansible
sudo pip3 install ./kolla-ansible
sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla
cp -r kolla-ansible/etc/kolla/* /etc/kolla
cp kolla-ansible/ansible/inventory/* .

#Kolla passwords
kolla-genpwd


tee /etc/kolla/globals.yml<<EOF
---
workaround_ansible_issue_8743: yes
kolla_base_distro: "ubuntu"
network_interface: "eth0"
neutron_external_interface: "eth1"
kolla_internal_vip_address: "$my_br_ip"
enable_cinder: "no"
enable_haproxy: "no"
EOF

#Deployment

kolla-ansible -i ./all-in-one bootstrap-servers
kolla-ansible -i ./all-in-one prechecks
kolla-ansible -i ./all-in-one deploy

#Using openstack

pip install python-openstackclient -c https://releases.openstack.org/constraints/upper/master
kolla-ansible post-deploy
. /etc/kolla/admin-openrc.sh
pip3 install python-openstackclient
/usr/local/share/kolla-ansible/init-runonce

# changing virt_type in nova-compute ----> nova.conf
sed -i 's/virt_type = kvm/virt_type = qemu/' /etc/kolla/nova-compute/nova.conf
sudo docker restart nova_compute

#Displaying message 
echo 🙌 Successfully deployed


#creating a VM
source /etc/kolla/admin-openrc.sh



# Displaying login password
cat /etc/kolla/passwords.yml | grep keystone_admin_password
