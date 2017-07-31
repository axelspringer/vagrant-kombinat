# -*- mode: ruby -*-
# # vi: set ft=ruby :

require 'fileutils'

Vagrant.require_version ">= 1.6.0"

# Make sure the vagrant-ignition plugin is installed
required_plugins = %w(vagrant-ignition)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

IGNITION_CONFIG_PATH = File.join(File.dirname(__FILE__), "config.ign")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Defaults for config options defined in CONFIG
$num_worker = 1
$num_nodes = $num_worker + 1

$enable_serial_logging = false
$share_home = false
$vm_gui = false
$vm_mem = 2048
$vm_cpus = 1
$vb_cpuexecutioncap = 100
$shared_folders = {}

$manager_ip = "172.17.8.2"
$worker_ip_base = "172.17.8."
$node_ips = $num_nodes.times.collect { |n| $worker_ip_base + "#{n+2}" }

if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true

  config.vm.box = "coreos-alpha"
  config.vm.box_url = "https://alpha.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json"

  config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']

  def customize_vm(config, name)
    config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--memory", $vm_mem]
      v.customize ["modifyvm", :id, "--cpus", $vm_cpus]

      # Use faster paravirtualized networking
      v.customize ["modifyvm", :id, "--nictype1", "virtio"]
      v.customize ["modifyvm", :id, "--nictype2", "virtio"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          
      # On VirtualBox, we don't have guest additions or a functional vboxsf
      # in CoreOS, so tell Vagrant that so it can be smarter.
      v.check_guest_additions = false
      v.functional_vboxsf     = false
      # enable ignition (this is always done on virtualbox as this is how the ssh key is added to the system)
      config.ignition.enabled = true

      config.ignition.config_vmdk = File.join(File.dirname(__FILE__), "config." + name + ".vmdk")
      config.ignition.config_img = "config." + name  + ".img"
      # # when the ignition config doesn't exist, the plugin automatically generates a very basic Ignition with the ssh key
      # # and previously specified options (ip and hostname). Otherwise, it appends those to the provided config.ign below
      if File.exist?(IGNITION_CONFIG_PATH)
        config.ignition.path = 'config.ign'
      end
    end
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define "manager" do |node|
    customize_vm node, 'manager'
    manager_ip = $manager_ip
    node.ignition.ip = $manager_ip
    node.vm.provision "shell", path: "provision-manager.sh", args: ["#{manager_ip}"]
    node.vm.network "private_network", ip: "#{manager_ip}"
    node.vm.hostname = "manager"
  end

  $num_worker.times do |n|
    config.vm.define "worker-#{n+1}" do |node|
      customize_vm node, "worker-#{n+1}"
      node_index = n+1
      node_ip = $node_ips[n + 1]
      manager_ip = $manager_ip
      node.ignition.ip = $node_ips[n + 1]
      node.vm.provision "shell", path: "provision-worker.sh", args: ["#{manager_ip}", "#{node_ip}"]
      node.vm.network "private_network", ip: "#{node_ip}"
      node.vm.hostname = "worker-#{node_index}"
    end
  end
end