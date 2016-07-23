# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.6.2"

Vagrant.configure(2) do |config|
  config.vm.define "vagrant-windows-2012-r2"
  config.vm.box = "vmware/windows_2012_r2"
  config.vm.communicator = "winrm"

  config.winrm.username = "vagrant"
  config.winrm.password = "vagrant"

  config.vm.guest = :windows
  config.windows.halt_timeout = 15

  config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
  config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true

  [:vmware_fusion, :vmware_workstation].each do |provider|
    config.vm.provider provider do |v, override|
      v.vmx["memsize"] = "2048"
      v.vmx["numvcpus"] = "2"
      v.vmx["ethernet0.virtualDev"] = "vmxnet3"
      v.vmx["RemoteDisplay.vnc.enabled"] = "false"
      v.vmx["RemoteDisplay.vnc.port"] = "5900"
      v.vmx["scsi0.virtualDev"] = "lsisas1068"
    end
  end

  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Expose every directory pointed to by a symlink in this directory.
  # For example: "ln -s $HOME/dev/dcp dcp" to mount $HOME/dev/dcp at /dcp.
  Dir["*"].each do |e|
    next unless File.symlink?(e)

    dst = File.readlink(e)
    next unless File.directory?(dst)

    config.vm.synced_folder dst, "/" + File.basename(e)
  end

  config.vm.provision "shell",
                      path: "provision.ps1"
end
