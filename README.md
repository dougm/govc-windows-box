# Windows Vagrant Box

NOTE: code/doc here has some internal references, but should still be useful as an example of taking a packer built
Vagrant box and deploying it to ESX.

For a Linux based example see: https://github.com/vmware/vic/tree/master/infra/machines/devbox

## Overview

This box is a Windows Server 2012R2 VM with the following setup:

* KMS activation

* Windows firewall and IE "enhanced security" disabled

* git, jdk8 and maven installed

* Machine wide environment variables set for using the software listed above

## Requirements

* Vagrant (https://www.vagrantup.com/downloads.html)

* VMware Fusion

* Vagrant Fusion license (https://www.vagrantup.com/vmware)

## Instructions

### Shared Folders

If you wish to access folders on your Mac from the Windows VM, simply create symlinks in this directory.
Folders will be mounted within the VM on the C: drive with a shortcut of the same name.  For example:

```bash
% ln -s ../../../dcp .
```

You can then access via *C:\dcp* within the VM.

### Add the Vagrant box

Note: this may take a while as the box is ~7.5G.

```bash
% vagrant box add --name vmware/windows_2012_r2 https://enatai-jenkins.eng.vmware.com/userContent/images/vagrant/windows_2012_r2_vmware.box
```

### Create the VM

```bash
% vagrant up
Bringing machine 'vagrant-windows-2012-r2' up with 'vmware_fusion' provider...
==> vagrant-windows-2012-r2: Cloning VMware VM: 'vmware/windows_2012_r2'. This can take some time...
==> vagrant-windows-2012-r2: Verifying vmnet devices are healthy...
==> vagrant-windows-2012-r2: Preparing network adapters...
==> vagrant-windows-2012-r2: Fixed port collision for 22 => 2222. Now on port 2200.
==> vagrant-windows-2012-r2: Starting the VMware VM...
==> vagrant-windows-2012-r2: Waiting for machine to boot. This may take a few minutes...
    vagrant-windows-2012-r2: WinRM address: 192.168.247.170:5985
    vagrant-windows-2012-r2: WinRM username: vagrant
    vagrant-windows-2012-r2: WinRM transport: plaintext
==> vagrant-windows-2012-r2: Machine booted and ready!
==> vagrant-windows-2012-r2: Forwarding ports...
    vagrant-windows-2012-r2: -- 3389 => 3389
    vagrant-windows-2012-r2: -- 22 => 2200
    vagrant-windows-2012-r2: -- 5985 => 55985
    vagrant-windows-2012-r2: -- 5986 => 55986
==> vagrant-windows-2012-r2: Configuring network adapters within the VM...
==> vagrant-windows-2012-r2: Configuring secondary network adapters through VMware
==> vagrant-windows-2012-r2: on Windows is not yet supported. You will need to manually
==> vagrant-windows-2012-r2: configure the network adapter.
==> vagrant-windows-2012-r2: Enabling and configuring shared folders...
    vagrant-windows-2012-r2: -- /Users/dougm/vmw/dcp: /dcp
==> vagrant-windows-2012-r2: Running provisioner: file...
==> vagrant-windows-2012-r2: Running provisioner: shell...
    vagrant-windows-2012-r2: Running: /Users/dougm/vmw/machines/vagrant/windows/provision.ps1 as c:\tmp\vagrant-shell.ps1
==> vagrant-windows-2012-r2: Setting KMS server...
==> vagrant-windows-2012-r2: Key Management Service machine name set to kms-win8.eng.vmware.com successfully.
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Activating installation against KMS...
==> vagrant-windows-2012-r2: Activating Windows(R), ServerStandard edition (b3ca044e-a358-4d68-9883-aaa2941aca99) ...
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Product activated successfully.
==> vagrant-windows-2012-r2: Disabling IE enhanced security...
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Disabling windows firewall...
==> vagrant-windows-2012-r2: Downloading git...
==> vagrant-windows-2012-r2: Installing git...
==> vagrant-windows-2012-r2: Adding git bin to system PATH...
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Downloading jdk8...
==> vagrant-windows-2012-r2: Installing jdk8...
==> vagrant-windows-2012-r2: Adding java bin to system PATH...
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Setting JAVA_HOME...
==> vagrant-windows-2012-r2: Downloading maven...
==> vagrant-windows-2012-r2: Unpacking maven...
==> vagrant-windows-2012-r2: Adding maven bin to system PATH...
==> vagrant-windows-2012-r2:
==> vagrant-windows-2012-r2: Finished
```

### RDP Access

RDP is much nicer than the Fusion console and fullscreen by default.

If you have */Applications/Remote Desktop Connection.app* installed, remove it via the Finder (not rm).

If you do not have */Applications/Microsoft Remote Desktop.app* installed, install via the App Store.

After running the command below, click *[Continue]* and enter *vagrant* when prompted for *Password*.

```bash
% vagrant rdp
```

### SSH Access

```bash
% vagrant ssh
```

### Stop the VM

```bash
% vagrant halt
```

### Restart the VM

```bash
% vagrant reload
```

### Provision

After you've done a `vagrant up`, the provisioning can be applied without reloading via:

```bash
% vagrant provision
```

### Delete the VM

```bash
% vagrant destroy
```

## ESX

See ./provision-esx.sh for deploying to ESX.

## Building the base box

Requirements:

* [packer](http://www.packer.io/downloads.html)

* [exit15](https://kb.eng.vmware.com/node/1431)

```bash
% git clone https://github.com/dougm/packer-windows.git
% cd packer-windows
% git checkout 2012-r2-volume-license
% cp /Volumes/home/ISO-Images/OS/Other/Windows/Server2012/R2/GA/Std_DataCtr/SW_DVD9_Windows_Svr_Std_and_DataCtr_2012_R2_64Bit_English_-2_Core_MLF_X19-31419.ISO .
% echo "packer build will take several hours to apply windows updates..."
% packer build -only=vmware-iso windows_2012_r2.json
% ls -l windows_2012_r2_vmware.box
```

See also:

[KMS Client Setup Keys](https://technet.microsoft.com/en-us/library/jj612867.aspx)
[KMS Activation](https://kb.eng.vmware.com/node/1361)
