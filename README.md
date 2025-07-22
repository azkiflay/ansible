# Ansible
Ansible is an open-source configuration management tool that orchestrates infrastructure such as virtual machines (VMs). While tools such as Vagrant and Terraform are Infrastructure as Code (IaC) systems, Ansible is widely adopted to manage the configuration of the infrastructure.

Ansible uses Yet Another Markup Language (YAML) to describe the desired state of infrastructure, making Ansible have a *declarative* configuration style rather than *imperative* where the user specifies detailed description of the infrastructure.

using Ansible (User and Group Mangement, Two-factor authentication over SSH, User security policy such as controlling user commands, Host-based Firewall Automation)
# Ansible for Configuraiton Management
Servers can be configured individually, but doing so is tiring, time-consuming and error prone. Ansible is a configuration management (CM) tool that enables system administrators to control state of servers. Puppet, Chef, and Salt are other CM tools. CM tools are used to define and enforce desired state for servers. For example, software package installation, configuration, permissions, and running the necessary services are among the things Ansible and other CMs can do. Ansible uses domain-specific language to describe the state of servers. Moreover, Ansible can be used for deployment of software ready to be released from a developers team. To achieve that, Ansible can copy the required files to servers, change configuration and environment variables, and start services in a particular order.

# Ansible Installation on Ubuntu 24.04 LTS
Source: https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible --version
```



# Telling Ansible About Your Servers
```bash
  cd ansible #
  mkdir inventory
  cd inventory
  touch vagrant.ini
  nano vagrant.ini
  ansible testserver -i ./inventory/vagrant.ini -m ping
```
