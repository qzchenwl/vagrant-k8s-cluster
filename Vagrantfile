# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    $num_nodes = 3
    (1..$num_nodes).each do |i|
        config.vm.define "k8s-cluster-node#{i}" do |node|
            node.vm.box = "centos/7"
            node.vm.synced_folder ".", "/vagrant", type: "virtualbox"
            node.vm.hostname = "k8s-node#{i}"
            ip = "10.0.0.#{i+100}"
            node.vm.network "private_network", ip: ip
            node.vm.provider "virtualbox" do |vb|
                vb.memory = "3072"
                vb.cpus = 2
                vb.name = "k8s-cluster-node#{i}"
            end

            node.vm.provision "shell", path: "bootstrap.sh"
            if i == 1
                puts "k8s-cluster-node#{i} is master"
                node.vm.provision "shell", path: "init-master.sh", privileged: false
            else
                puts "k8s-cluster-node#{i} is worker"
                node.vm.provision "shell", path: "init-worker.sh", privileged: false
            end
        end
    end
end
