# vagrant-k8s-cluster

Vagrantfile for k8s cluster of 3 node.

## Prerequisite

- Host: Linux
- Vagrant >= 2.0.3 with plugin vagrant-vbguest


## Start

```bash
$ git clone https://github.com/qzchenwl/vagrant-k8s-cluster
$ cd vagrant-k8s-cluster
$ vagrant up
```

### Manually download centos/7
```bash
$ wget -c http://cloud.centos.org/centos/7/vagrant/x86_64/images/CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box
$ vagrant box add CentOS-7-x86_64-Vagrant-1801_02.VirtualBox.box --name centos/7
```
