# -*- mode: ruby -*-
# vi: set ft=ruby :

PUBLIC_KEY_PATH = '/home/sai-wai-yan/pov-ansible/pov-ansible/.ssh/id_ed25519.pub'.freeze
Vagrant.configure("2") do |config|

    # We set up one machine, with a default NAT interface and a host-only 192.168.30.11
    # interface
    config.vm.define "dashboard" do |vm1|
      # config.ssh.private_key_path = "/home/sai/vagrantboxes/devbox03/.ssh/devbox03_rsa"
      # config.ssh.forward_agent = true
      # config.ssh.username = "vagrant"
      # config.ssh.password = "vagrant"
      vm1.vm.hostname = "dashboard"
      vm1.vm.box = "bento/ubuntu-24.04"
      vm1.vm.synced_folder ".", "/home/vagrant/", disabled: true
      vm1.vm.network "private_network", ip: "192.168.56.11"
      vm1.vm.provider "virtualbox" do |vb|
        vb.name = "dashboard"
      end
      config.vm.provision 'shell' do |shell|
        shell.inline = <<~DOC
          echo '#{IO.read(PUBLIC_KEY_PATH)}' >> /home/vagrant/.ssh/authorized_keys
        DOC
      end
      # vm1.vm.provision "shell", path: "dashboard-service.sh"
    end
    # and a second machine with a NAT interface and again a host-only interface 192.168.30.12
    # connected to the same network
    config.vm.define "counting" do |vm2|
      # config.ssh.private_key_path = "/home/sai/vagrantboxes/devbox03/.ssh/devbox03_rsa"
      # config.ssh.forward_agent = true
      # config.ssh.username = "vagrant"
      # config.ssh.password = "vagrant"
      vm2.vm.hostname = "counting"
      vm2.vm.box = "bento/ubuntu-24.04"
      vm2.vm.synced_folder ".", "/home/vagrant/", disabled: true
      vm2.vm.network "private_network", ip: "192.168.56.12"
      vm2.vm.provider "virtualbox" do |vb|
        vb.name = "counting"
      end
      config.vm.provision 'shell' do |shell|
        shell.inline = <<~DOC
          echo '#{IO.read(PUBLIC_KEY_PATH)}' >> /home/vagrant/.ssh/authorized_keys
        DOC
      end
      # vm2.vm.provision "shell", path: "counting-service.sh"
    end
  end