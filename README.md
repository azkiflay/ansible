
# Introduction
This section introduces Ansible, a popular Configuration Management (CM) tool. </br>
Online services and applications are supported by physical and virtual servers. These servers can be configured individually, but doing so is tiring, time-consuming and error prone. Ansible is an open-source CM tool that enables system administrators to control the state of servers. [Puppet](https://www.puppet.com/), [Chef](https://www.chef.io/products/chef-infra), and [Salt](https://saltproject.io/) are other CM tools. CM tools are used to define and enforce desired state for servers, as well as other networked hosts and devices. For example, software package installation, configuration, permissions, and running the necessary services are among the things Ansible and other CMs can do. 

Ansible is written in Python, and it uses a domain-specific language ([DSL](https://en.wikipedia.org/wiki/Domain-specific_language)) to describe the state of servers. Moreover, Ansible can be used for deploying software that is ready to be released from a developers team. To achieve that, Ansible copies required files to servers, change configuration and environment variables, and start services in a particular order. 

<!-- Moreover, Ansible orchestrates infrastructure such as virtual machines (VMs) and containers. -->
While tools such as [Vagrant](https://developer.hashicorp.com/vagrant) and [Terraform](https://developer.hashicorp.com/terraform) are systems that orchestrate infrastructure such as virtual machines (VMs) and containers, Ansible manages the configuration of the infrastructure. Terraform and Vagrant are Infrastructure as Code (IaC) tools. Once server infrastructure has been created using IaC tools, Ansible automates the configuration, versioning, and management of the infrastructure. 

Ansible utilizes Yet Another Markup Language (YAML) to describe the desired state of infrastructure. As a result, Ansible has a *declarative* configuration style rather than *imperative*. In the case of the latter, the user is required to specify the exact details of the infrastructure, while a simpler description suffices in Ansible.

Moreover, unlike other CM systems, Ansible is agentless, meaning it does not require a software agent to be installed on managed hosts. This reduces security risks and administration costs. Because Ansible is installed only at a controller node and not at the managed hosts. From the controller node, Ansible uses Secure Shell (SSH) to push configuration to the managed hosts and make the desired changes accordingly. With SSH being the most secure method to connect to remote hosts, Ansible leverages SSH to configure a number of servers remotely.

<!-- Using Ansible (User and Group Mangement, Two-factor authentication over SSH, User security policy such as controlling user commands, Host-based Firewall Automation) -->

# Terminology and Workflow
Ansible terms and workflow are summarized in this seciton. </br>
* **Control node**: a Linux/Unix machine where Ansible has been installed. It is possible to have more than one control nodes. A Windows machine cannot be a control node.
* **Managed nodes (hosts)**: Network devices or servers managed by Ansible. Managed hosts do not have have Ansible installed on them.
* **Inventory**: a file that contains a list/group of hosts that an Ansible control node works with. Inventory file is created at the control node, specifying details of managed hosts such as IP addresses or domain names. Host information in an inventory file can be organized in groups and subgroups. An inventory file is a text file that is usually created with an **.ini**, **.yml** extension, or no extension.
* **Module**: a piece of code that Ansible executes to perform specific actions on different operating systems and environments. One more more modules can be used in *tasks* and *playbooks*.
* **Tasks**: Units of action in Ansible. For example, a command to install software on a managed host is a task.
* **Playbook**: an *ordered lists of tasks* used to configure remote hosts. Playbooks are run in a control node to configure remote hosts. **YAML** is used to write playbooks, which can include tasks and variables.

Broadly, the **Ansible workflow** includes the following major steps:
* Ansible controller uses **SSH to connect** to a host or groups of hosts.
* The controller makes changes to host(s) using **ad hoc commands** or using an **inventory file**.
* **Transfers** one or more **modules** to host(s).
* **Executes the module(s)** at the host(s).

# Installation
The following commands can be used to install Ansible on [Ubuntu](https://ubuntu.com/) Operating System (OS). While Ubuntu 24.04 LTS was used in this tutorial, the commands will likely work on other Ubuntu distributions with minor changes, if any.

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
ansible --version
```
Instructions to install Ansible in other major OSes are available [here](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html).

# SSH Configuration
In this section, steps that enable the controller to connect with managed hosts are discussed. </br>
Before the controller can do anything on managed hosts, it needs to be connected to them. As stated earlier, such network connection is setup using **SSH**. Therefore, it is important to ensure SSH is available and configured correctly on the controller and managed hosts. 

Moreover, to avoid a rogue controller taking over the infrastructure, a key-based or password-based authentication must be enforced. In most cases, a key-based authentication is preferrable. Steps to configure public and private keys for SSH, requiring the controller to be authenticated by the managed hosts, are shown below.

When a key-based authentication is setup, managed hosts use public key of the Ansible controller to authenticate it. The controller's private key should be kept locally and securely. In other words, the public key should be known to the managed nodes for them to be able to create a message that can be read only using the private key of the controller node. The rest of the authentication process is automatically triggered at each node after the private and public key pair have been configured at the respective hosts.

To this end, public and private keys are generated at the controller. Subsequently, the controller's public key has to be transferred to the managed hosts, letting them know about the controller and its public key. This requires a valid user name and password to access a managed host and transfer the controller's public key. 

Put another way, to configure the controller connection with the managed hosts using a key-based authentication, the controller's private and public keys must be available at the right places. However, before the key-based authentication can be configured, there must be a pre-existing password-based access to the managed hosts from the controller.

## Creating public and private keys
The *ssh-keygen* command is widely used to create the private and public keys for and at the controller. For example, the following creates private and public keys and saves them inside the *~/.ssh* directory. In this case, the file name of the private key is *ansible_key*, while the public key is *ansible_key.pub*. While any name can be given for the key pairs, the *ssh-keygen* command provides default names of *id_rsa*, and *id_rsa.pub*, for the private and public keys, respectively.

```bash
  ssh-keygen -t rsa -f ~/.ssh/ansible_key
  ls -l ~/.ssh/ansible_key # Private key permissions
  nano  ~/.ssh/ansible_key # View the private key
  ls -l ~/.ssh/ansible_key.pub # Public key permissions
  nano ~/.ssh/ansible_key.pub # View the public key
```

## Transferring the public key to hosts
To be able to transfer the controller's public key to the managed hosts, you need to have an existing password-based access to the latter. In other words, you should already be able to use *ssh* to login remotely to the managed hosts, using the respective user name and password at each host, as shown in the following example.

```bash
  ssh myname@192.168.0.10 # Replace myname & IP with your own.
```

After ensuring the managed hosts can be accessed using a password-based authentication, the next step is to configure *ssh* to use the private and public keys created earlier for authenticating the Ansible controller with the managed hosts. 

However, the managed hosts do not have the public key of the controller yet. Therefire, you need to transfer the public key to the hosts first. To do that, *ssh-copy-id* command followed by each host's IP address or domain name is used as shown in the following example.

```bash
  # ssh-copy-id --> uses locally available keys to authorise logins on a remote machine
  ssh-copy-id -i ~/.ssh/azkiflay.pub myname@192.168.0.10 
```
Note that the public key was created with a custom name earlier. Therefore, that the name of the public key has to be specified using the *-i* option. A passphrase is requested to access the private key, "azkiflay" in this case, as shown in Figure 1. The password of the user account where the key pair were created is the passphrase. Enter that to proceed.
<p align="center">
  <img src="figures/ssh_copy_id_1.png" width="500" height="200"/>
</p>
<p align="center"><strong>Figure 1:</strong> Unlocking the private key </p>

Following a successful entry of a password, the public key of the Ansible controller is added to the managed host as depicted in Figure 2.
<p align="center">
  <img src="figures/ssh_copy_id_2.png" width="500" height="300"/>
</p>
<p align="center"><strong>Figure 2:</strong> Transferring public key to a remote host </p>

Consequently, the public key of the Ansible controller has been copied to the remote host's authorized_keys file. Therefore, the controller can now access the remote managed host without a password, using the public key. As shown in Figure 3, when "*ssh myname@192.168.0.10*" is issued to access the managed host, no prompt appears asking for a password.

```bash
  ssh myname@192.168.0.10 
  # ssh -p port_number myname@192.168.0.10 # If ssh is not running on the default port number 22
  # ssh myname@192.168.0.10 command_to_run # To execute a single command on a remote system
  # ssh -X myname@192.168.0.10 # If X11 forwarding is enabled on both local and remote systems
  exit # Terminate the connection
```

The reason for the passwordless login is because the public key of the controller has now been added to the managed host's **authorized_keys** file. The presence of the public key at the managed host can be verified by connecting to it, and running "*cat ~/.ssh/authorized_keys*" on the terminal. With regards to the private key, the clue is in the name. It should be kept private and secure at the controller, which uses it to decrypt messages from managed hosts. 

Figure 3 depicts that the Ansible controller has been successfully authenticated by the managed host (192.168.0.10). This was possible because the host has the controller's public key in its *authorized_keys* files, also shown in the second line of the "* cat ~/.ssh/authorized_keys*"" command issued at the managed host.

<p align="center">
  <img src="figures/ssh_public_key_login.png" width="600" height="300"/>
</p>
<p align="center"><strong>Figure 3:</strong> Public key-based access to a managed host </p>

# Inventory
Ansible is a CM system, and for the controller to enforce any sort of configuration changes on manages hosts, first it must keep a list of the servers using their IP addresses or domain names. Such a list is known as **inventory file**, which Ansible uses to track the servers that it manages. 

The default location for a system-wide inventory file is under "*/etc/ansible/hosts*". But this is not always the case, depending on the way Ansible is installed. For example, the "*apt*"-based installation in Ubuntu 24.04 does not create "*/etc/ansible/hosts*". In any case, it is recommended to maintain an inventory file for each project separately. 

Conveniently, the inventory file can be named "*inventory.ini*" or "*hosts.ini*". But it can also be given any other valid file name. While it is also possible to create the inventory file without any file extension, another common way to create the inventory file is as a YAML ("*.yml*") file. Essentially, the inventory file contains a list of hosts that the Ansible controller manages. Several hundreds and thousands of hosts can be administered using Ansible.

For for example, the following creates an inventory file in the current directoy.
```bash
  nano ./inventory.ini
```
The following shows sample contents of the *inventory.ini* file, listing five servers in it. Four of the servers are under two groups, *group1* and *group2*, while the first server is not grouped.
```bash
  192.168.0.10
  [group1]
  192.168.0.11
  192.168.0.12
  [group2]
  192.168.0.13
  192.168.0.14
  [group3]
  192.168.0.12
  192.168.0.13
```

Alternatively, the same inventory file can be created in YAML.
```bash
  nano ./inventory.yml
```
```bash
  all:
    hosts:
      192.168.0.10
      children:
        group1:
          hosts:
            192.168.0.11
            192.168.0.12
        group2:
          hosts:
            192.168.0.13
            192.168.0.14
        group3:
          hosts:
            192.168.0.12
            192.168.0.13
```
By default, there are **all** and **ungrouped** groups in Ansible. The former contains all hosts, while the latter contains hosts that do not belong to another group except the *all* group. In the above example, the host 192.168.0.10 belongs to *ungrouped*. The hosts 192.168.0.11 and 192.168.0.12 are members of *group1*. Hosts 192.168.0.13 and 192.168.0.14 belong to *group2*. Lastly, *group3* consists of hosts 192.168.0.12 and 192.168.0.14. Every host is a member of the *all* group. A host can belong to more than one group. These group memberships can be view using "*ansible-inventory -i inventory.ini --list".

```bash
  ansible-inventory -i inventory.ini --list # ansible-inventory -i inventory.yml --list
```

Group memberships of a host are usually determined by *what* the host does, *where* it is located, and *when* in the development pipeline it is utilized. 

There are ways to create hosts in an inventory using pattern matching, adding a range rather than listing each host. For example, *www[01:50].local* creates *50* hosts, while db-[a:z].local creates *26* hosts.


# Ad Hoc Commands
The whole point of automation using Ansible is to realize a change of state at the managed hosts. Restarting a server, creating users, copying files are examples of such changes of state, all of which can be implemented using **ad hoc tasks** or **playbooks**.

Considering the hosts defined in the *inventory.ini* file earlier, let us utilize ad hoc commands to check connectivity of the controller to the managed hosts. In the following, hosts in *group2* are tested for connectivity. In this example, you can see that *ping* is used to test reachabiligy of the managed host from the controller. 

```bash
  ansible -i inventory.ini group2 -m ping -u azkiflay
```
 Note the *-i*, *-m*, and *-u* options are used to specify the inventory file at the controller, the command to execute, and a user name at the managed host, respectively. Particularly, the "*-m*" option stands for *module*, requesting for the *ping* module to be executed. The user account on the managed host is identified by the "*-u*" option. The results are shown in Figure 4 below.

<p align="center">
  <img src="figures/ansible_ad_hoc_ping_3.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 4:</strong> Checking controller's to a host group using ad hoc command </p>


It is also possible to check connectivity to individual managed hosts. For example, Figure 5 shows the results of such ad hoc ansible task that tests connectivity. The ping results indicate that the controller can reach both hosts successfully.
<p align="center">
  <img src="figures/ansible_ad_hoc_ping.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 5:</strong> Checking connectivity to individual hosts using ad hoc command </p>

If there is a problem in connectivity, Ansible provides a clear error mesage. For example, some connection tests failed in the following.

```bash
  ansible -i inventory.ini all -m ping # all --> target all hosts in that inventory.
```

The above ad hoc command results in "UNREACHABLE!" error for both hosts. Paricularly, the *msg* part of the results states ""msg": "Failed to connect to the host via ssh: aheb@192.168.0.10: Permission denied (publickey,password)". This makes sense because the local user name *aheb* does not exist on both of the hosts in the inventory.ini file. 

To tackle this problem, the user name on a host can be specified using the *-u* option, as has been done in the following.

```bash
  ansible -i inventory.ini all -m ping -u azkiflay # returns error on one of the hosts, but successful on the other host
```

Figure 6 shows the full results of the various ad hoc commands that test connectivity of the ansible controller and the hosts in its inventory.ini file.
<p align="center">
  <img src="figures/ansible_ad_hoc_ping_2.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 6:</strong> Checking controller's to hosts using ad hoc command </p>

Having tested the connectivity, you can issue ad hoc commands to get some details about the hosts in the inventory.ini file. For example, from the controller, the "free -h" command can be run on the myname_host(*192.168.0.11*), and azkiflay_host (*192.168.0.10*) hosts, obtaining the results shown in Figure 7.

```bash
  ansible -i inventory.ini azkiflay_host -a "free -h" -u azkiflay
  ansible -i inventory.ini myname_host -a "free -h" -u azkiflay
```

<p align="center">
  <img src="figures/ansible_ad_hoc_host_info.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 7:</strong> Getting memory details of hosts using ad hoc commands </p>



# Provisioning with Vagrant
This section discusses how infrastructure can be tested locally using Vagrant IaC, VirtualBox, and Ansible as CM to provision a new server. </br>

<!--
Broadly speaking, DevOps is about collaboration between development and operations teams. This tutorial demonstrates various concepts and tools for DevOps. In particular, concepts such as *Infrastructure as Code (IaC)*, *Configuraation Management (CM)*, *Containerization and Orchestration*, *Delivery*, *Monitoring and Alerting*, and *Troubleshooting* will be covered.

* Infrastructure as Code (IaC) means using code to describe and manage infrastructure like VMs, network switches, and cloud resources.
* Configuration Management (CM) is the process of configuring the resources described in IaC for a specific purpose in a repeatable and predictable manner.

* Microservices, cloud-based and containerized applications, automated CI/CD pipelines, observability through logging, monitoring and alerting.
* Collaboration of feature teams (development) and operations/sysadmin teams to deliver predictable and reliable software.

* Introduction
* Infrastructure as Code (IaC) using Vagrant, Terraform ("Building systems with a repeatable, versioned, and predictable state.")

* Docker for Containerized Application
* Kubernetes and Minikube for Container Orchestration (Kubernetes manifests, Microservices)
* Skaffold to create a CI/CD pipeline on a local Kubernetes cluster (Automated code delivery using Continuous Integration and Continous Delivery (CI/CD) pipelines)
  ** Jenkins
* Prometheus, Alertmanager, Grafana for Observability (logging, tracing, monitoring and alerting)
* Troubleshooting Hosts
* Real-world applications/projects -- Moodle
-->

## Setting Up a Virtual Machine
While a cloud-based environment is the most common scenario, sometimes it is necessary to test the infrastructure in a local environment. Most of the configurations and commands can also work in a cloud-based environment with minor modifications. To simulate multiple hosts locally, this tutorial uses a VirtualBox as a virtualization software.

To run an application within a virtual machine (VM), the VM needs to be created first. Subsequently, the VM and the application need to be configured in a specific way. In DevOps lingo, these steps are called *provisining*, and *configuration management*, respectively. Provisining can be done using tools such as *Vagrant* and *Terraform*, while *Ansible* is a popular configuration management tool. Vagrant and Ansible are used in this tutorial. Vagrant is an IaC tool, whereas Ansible is a CM tool.

## VirtualBox Installation on Ubuntu 24.04 LTS
* Download and install VirtualBox for Ubuntu/Debian from https://www.virtualbox.org/wiki/Downloads/. Download the VirtualBox *.deb* package for Ubuntu 20.04 if you would like to follow a similar environment as in this tutorial. For the purposes of this tutorial, the host machine is running Ubuntu 24.04 LTS, while the VM that will be created and managed will be Ubuntu 20.04. The reason for the later is because that is latest distribution available from Vagrant.
  ```bash
    #!/bin/bash
    sudo apt update
    sudo apt install -y build-essential dkms linux-headers-$(uname -r)
    sudo apt install virtualbox-7.1 # sudo apt remove virtualbox-7.1
    sudo apt --fix-broken install
    sudo dpkg -i ~/Downloads/virtualbox-7.1_7.1.12-169651~Ubuntu~focal_amd64.deb # TO ROMOVE: sudo apt remove virtualbox
    sudo apt install virtualbox-guest-additions-iso # TO REMOVE: sudo apt remove virtualbox-guest-additions-iso # If mismatch with Vagrant's expected version, 'vagrant up' won't work.
    vagrant plugin install vagrant-vbguest # On your host machine, install the vagrant-vbguest plugin
  ```
<!-- # Infrastructure as Code -->
## Vagrant for Infrastructure as Code
Vagrant is an IaC tool that is utilized for creating and managing VMs. To describe the VM infrastructure, Vagrant uses a file named Vagrantfile. To manage infrastructure, first Vagrant needs to be installed in the local host.

## Vagrant Installation on Ubuntu 24.04 LTS
```bash
  #!/bin/bash
  wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg # On "Enter new filename: ", input a file name, say 'vagrant'.
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install vagrant
  vagrant --version # For a successful installation, this returns something like "Vagrant 2.4.7".
```

## Testing Vagrant
```bash
  mkdir playbooks
  cd playbooks
  vagrant init ubuntu/focal64
```
The last command will display a message stating that a "Vagrantfile" has been placed in the current directory as shown in Figure 8 below. 
<p align="center">
  <img src="figures/vagrantfile.png" width="400" height="300" />
</p>
<p align="center"><strong>Figure 8:</strong> Vagrantfile </p>

The following *vagrant up* command creates the VM according to the Vagrantfile. Figure 9 shows the progress of creating the VM infrastructure.

```bash
  vagrant up
``` 
<p align="center">
  <img src="figures/vagrant_up.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 9:</strong> Creating as per Vagrantfile </p>

It can be seen that "ubuntu/focal" has been imported for installation. Other available Ubuntu distributions that can be installed using Vagrant are availabe at https://portal.cloud.hashicorp.com/vagrant/discover. Moreover, the VM has been given a name that starts with the current working directory (*playbooks*) followed by *default* and a number string. After other similar configurations are made, the VM is finally booted up and ready for use.

It is important to note that if the Vagrantfile does not exist, *vagrant up* will not work. In this case, Vagrantfile is under the *playbooks* directory. To see what happens when the Vagrantfile is not present in the working directory, lets move up to the parent directory of *playbooks* and run *vagrant up* from there.

```bash
  cd ..
  ls -a # No Vagrantfile here
  vagrant up
```
Since there is not Vagrantfile in the directory, the *vagrant up* command returns the results shown in Figure 10.
<p align="center">
  <img src="figures/vagrant_up2.png" width="400" height="300"/>
</p>
<p align="center"><strong>Figure 10:</strong> Attempting to create VM without Vagrantfile </p>

Therefore, it is important to ensure there is a Vagrantfile present. The best practice is to have a Vagrantfile for each IaC project.
Vagrantfile is a description of how a VM should be buit and provided. The file is written in Ruby programming language. Vagrant support many OS images, which are referred to as *boxes*. The list OSes supported by Vagrant can be found [here](https://portal.cloud.hashicorp.com/vagrant/discover). To specificy the OS image, Vagrant uses *config.vm.box* entry in Vagrantfile. For example, "config.vm.box = "ubuntu/focal64" describes an Ubuntu 20.04 base image for installation.

Figure 11 shows a screenshot of a sample Vagrantfile utilized for this tutorial.
Since there is not Vagrantfile in the directory, the *vagrant up* command returns the results shown in Figure 10.
<p align="center">
  <img src="figures/vagrantfile2.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 11:</strong> Vagranfile Example </p>

In the above sample Vagrantfile, it can be seen that the VM's hostname has been set to "azkiflay", while the *network* has been configure *public_network* to use a *bridge* to the hosts Wi-Fi interface (*wlo1*).

The following commands show various changes on a VM instance.
```bash
  vagrant up # Starts and restarts a VM according to Vagrantfile
  vagrant halt # Shuts down a running VM forcefully
  vagrant destroy # Deletes a running VM
  vagrant suspend # Suspends the VM
  vagrant up
  vagrant status # Checks that status of a running VM
  vagrant ssh # Connects to the VM over a Secure Shell (SSH)
```

With the VM running, we can connect to it using *vagrant ssh*. Figure 12 a screenshot of a connection to the Ubuntu 20.04 VM running inside VirtualBox as discussed earlier. Basic OS details of the VM can be seen after the connection using SSH.
<p align="center">
  <img src="figures/vagrant_ssh.png" width="600" height="400"/>
</p>
<p align="center"><strong>Figure 12:</strong> SSH connection to the VM </p>


<!--
```bash
  #!/bin/bash
  ssh-keygen -t rsa -f ~/.ssh/azkiflay -C azkiflay
  ls -lh ~/.ssh/
  nano ~/.ssh/azkiflay # Private key
  nano ~/.ssh/azkiflay.pub # Public key
  vagrant ssh
  vagrant ssh-config
  ssh vagrant@127.0.0.1 -p 2222 -i /media/HD1TB/devops/devops_for_the_desperate/vagrant/.vagrant/machines/default/virtualbox/private_key
  vagrant provision
  ssh -i ~/.ssh/azkiflay -p 2222 azkiflay@localhost
  su vagrant # Change to vagrant user. Default password: vagrant
```
-->


# Ansible Playbooks
While ad hoc commands are useful for running one-off tasks, they are not suitable for many tasks that have to be done in a repeatable manner, at different hosts and times. On the other hand, automation, repeatability and version control are some of Ansible's great features. That's where **playbooks** come in. Playbooks are a set of instructions (an *ordered list of tasks*) that aim to bring server(s) to a specific configuration state. Playbooks are written in YAML, and they are to be executed (*played*) on the managed server(s). A playbook can be a subset of another playbook, whose task gets extended due to the addition of the subset playbook.

To illustrate, assume you want to remove an existing *Apache2* installation from the 192.168.0.10 host. Shell commands are one way to do that. As discussed earlier, ad hoc commands in ansible can be used to issue one-off shell commands. Alternatively, you can *ssh* to the remote host and run the commands step-by-step to unistall the *Apache2* package. Since the ad hoc commands require setting various options as shown earlier, let us just *ssh* to the host and uninstall *Apache2* as shown below. Let us save the shell script as "*remove_apache.sh*" at the controller. 


<!--
```bash
  #!/bin/bash
  apache2 -v
  systemctl stop apache2 # Stop Apache
  systemctl disable apache2 # Disable Apache
  apt purge apache2 -y # Purge Apache packages and clean up dependencies
  apt autoremove -y
  apt autoclean
  rm -rf /etc/apache2 # Remove Apache configuration directory  
  rm -rf /var/log/apache2 # Remove Apache log files
  rm -rf /var/www/html # Remove default web root (CAUTION: deletes /var/www/html)
  rm -rf /var/www
  which apache2 || echo "apache2 not found" # Verify apache2 binary no longer exists
  systemctl status apache2 || echo "apache2 service not found" # Verify apache2 service no longer exists
```

However, you want to execute the shell script at the remote host. Therefore, first the file has to be copied over to the managed host. You can use *scp* or *rsync* commands for that purpose as shown in the following. Subsequnetly, the shell script can be run to uninstall the Apache2 software.
-->


<!--
```bash
  #!/bin/bash
  scp remove_apache.sh azkiflay@192.168.0.10:/tmp/remove_apache.sh # Or rsync -avz remove_apache.sh azkiflay@192.168.0.10:/tmp/remove_apache.sh
  ssh azkiflay@192.168.0.10
  sudo sh /tmp/remove_apache.sh # If successful, returns "apache2 service not found" message at the end.
```
-->


<!--
You may be wondering what is the problem with the above shell script. After all, it does what is supposed to do, at least in this case. The problem arises when you want apply a similar set of operation on multiple servers in a repeatable and safe manner. That is where ansible playbooks come in.

To easily compare with the previous commands for unistalling Apache, let us convert the contents of "*remove_apache.sh*" shell script to an equivalent ansible playbook. First, the apache2 package needs to be installed at the 192.168.0.10 machine, as the package was removed by the "*remove_apache.sh" script. Let us save the script in a "*install_apache.sh*". Subsequently, the script is copied over to the target host and run there to install *apache2*.
-->


<!--
```bash
  #!/bin/bash
  echo "=== Updating package list ==="
  apt update
  echo "=== Installing Apache2 ==="
  apt install apache2 -y
  echo "=== Recreating default web root directories ==="
  mkdir -p /var/www/html
  chown -R www-data:www-data /var/www
  chmod -R 755 /var/www
  echo "=== Enabling and starting Apache2 service ==="
  systemctl enable apache2
  systemctl start apache2
  echo "=== Verifying Apache2 installation ==="
  apache2 -v || echo "Apache2 not found"
  systemctl status apache2 --no-pager || echo "Apache2 service not found"
  echo "=== Apache2 reinstallation complete! ==="
```
-->


<!--
  ```bash
  #!/bin/bash
  rsync -avz install_apache.sh azkiflay@192.168.0.10:/tmp/install_apache.sh # Or scp remove_apache.sh azkiflay@192.168.0.10:/tmp/remove_apache.sh
  ssh azkiflay@192.168.0.10
  sudo sh /tmp/install_apache.sh # If successful, returns "apache2 service not found" message at the end.
```
-->

<!--
Run the remove_apache.yml playbook as follows:
```bash
  #!/bin/bash
  ansible-playbook -i inventory.ini install_apache.yml --list-hosts # View affected hosts
  ansible-playbook -i inventory.ini remove_apache.yml -u azkiflay --become  --ask-become-pass # state: absent to remove package
```
-->

<!--
To run the install_apache.yml playbook:
```bash
  #!/bin/bash
  ansible-playbook -i inventory.ini install_apache.yml -u azkiflay --become  --ask-become-pass # state: present, state: latest -- to install package
```
-->


<!-- # Sample Application -->
<!-- Moodle 
## Local
-->

<!--
```bash
  #!/bin/bash
  ansible-galaxy collection install community.general
  ansible-galaxy collection install community.mysql
  ssh azkiflay@192.68.0.11
  sudo apt install python3-pip
  exit
  ansible-playbook -i inventory.ini playbook.yml -u azkiflay --become --ask-become-pass --limit azkiflay_host  --check 
  ansible-playbook -i inventory.ini playbook.yml -u azkiflay --become --ask-become-pass --limit azkiflay_host 
  ansible-playbook -i inventory.ini playbook.yml -u azkiflay --become --ask-become-pass --limit azkiflay_host  --check 
  ansible-playbook -i inventory.ini playbook.yml -u azkiflay --become --ask-become-pass --limit azkiflay_host
  ansible-playbook -i inventory.ini playbook.yml --become -ask-become-pass --limit azkiflay_vm
```
-->


<!--
```bash
  #!/bin/bash
  ansible-playbook -i inventory.ini playbook.yml --limit ubuntuserver_vm1 -u azkiflay --become --ask-become-pass --check
```
-->


<!--
```bash
  #!/bin/bash
  vagrant box add geerlingguy/rockylinux8 # Downloads Rocky Linux for virtualbox
  vagrant init geerlingguy/rockylinux8 # Creates `Vagrantfile` in current directory
  vagrant up
  vagrant ssh
  vagrant ssh-config
  vagrant halt
  vagrant destroy
```
-->


<!--
# Future
* Packer: Build the base images (optional).
* Terraform: Provisions infrastructure (VMs, networks, cloud services), and deploy the image at scale in cloud or on-prem.
* Ansible: Configures the OS and software inside those machines
* Vagrant: used to spin up dev/test VMs quickly and to test the image locally.
* WinRM and SSH based connection between Ansible controller and managed hosts
* Real-world Ansible usage scenarios/projects


# Refrences
* Ansible for DevOps Server and configuration management for humans 2nd Edition, Jeff Geerling, Lean Publishing, 2023
  ** git clone https://github.com/geerlingguy/ansible-for-devops
* Ansible Website, https://docs.ansible.com/, Accessed 24 July - 8 August, 2025
* DevOps for the Desperate A Hands-on Survival Guide, Bradley Smith, No Starch Press, 2022
* Moodle: https://docs.moodle.org/500/en/Step-by-step_Installation_Guide_for_Ubuntu
-->