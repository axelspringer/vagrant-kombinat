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

# Constants
IGNITION_CONFIG_PATH = File.join(File.dirname(__FILE__), "config.ign")
CONFIG = File.join(File.dirname(__FILE__), "config.rb")

# Defaults for config options defined in CONFIG
$num_worker = 2
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

# local config
if File.exist?(CONFIG)
  require CONFIG
end

Vagrant.configure("2") do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false
  # forward ssh agent to easily ssh into the different machines
  config.ssh.forward_agent = true

  # CoreOS
  config.vm.box = "coreos-beta"
  config.vm.box_url = "https://beta.release.core-os.net/amd64-usr/current/coreos_production_vagrant_virtualbox.box"

  # synced Folder, used to distribute worker_token
  config.vm.synced_folder ".", "/home/core/share", id: "core", :nfs => true,  :mount_options   => ['nolock,vers=3,udp']

  # VirtualBox
  def customize_vm(config, name)
    config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", $vm_mem]
      vb.customize ["modifyvm", :id, "--cpus", $vm_cpus]

      # Use faster paravirtualized networking
      vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
      vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
          
      # On VirtualBox, we don't have guest additions or a functional vboxsf
      # in CoreOS, so tell Vagrant that so it can be smarter.
      vb.check_guest_additions = false
      vb.functional_vboxsf     = false
      # enable ignition (this is always done on virtualbox as this is how the ssh key is added to the system)
      config.ignition.enabled = true

      # Ignition Config
      config.ignition.drive_root
      config.ignition.drive_name = "config." + name
      config.ignition.config_obj = vb
      config.ignition.hostname = name
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

  # config Swarm Manager
  config.vm.define "manager" do |node|
    manager_ip = $manager_ip
    
    node.ignition.ip = $manager_ip
    node.vm.provision "shell", path: "provision-manager.sh", args: ["#{manager_ip}"]
    node.vm.network "private_network", ip: "#{manager_ip}"
    node.vm.hostname = "manager"

    customize_vm node, 'manager'

  end

  # config Swarm Workers
  $num_worker.times do |n|
    config.vm.define "worker-#{n+1}" do |node|
      manager_ip = $manager_ip

      node_index = n+1
      node_ip = $node_ips[n + 1]

      node.ignition.ip = $node_ips[n + 1]
      node.vm.provision "shell", path: "provision-worker.sh", args: ["#{manager_ip}", "#{node_ip}"]
      node.vm.network "private_network", ip: "#{node_ip}"
      node.vm.hostname = "worker-#{node_index}"
      
      customize_vm node, "worker-#{n+1}"
    end
  end
end