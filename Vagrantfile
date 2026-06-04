require 'yaml'
GLOBAL_VARS = YAML.load_file(File.expand_path('../global_vars.yml', __FILE__))
VM_NAME = GLOBAL_VARS.fetch('VM_NAME')
SSH_USER = GLOBAL_VARS.fetch('SSH_USER')

Vagrant.configure("2") do |config|
  # Base box
  config.vm.box = "debian/bookworm64"
  config.vm.hostname = VM_NAME
  config.vm.define VM_NAME
  config.vm.synced_folder "../../../ops", "/home/#{SSH_USER}/ops", owner: SSH_USER, group: SSH_USER

  # NIC
  config.vm.network "private_network", ip: "192.168.56.10"

  # Provider settings
  config.vm.provider "virtualbox" do |vb|
    vb.name   = VM_NAME
    vb.memory = 8192
    vb.cpus   = 4
  end
  # Provisioning minimal
  config.vm.provision "shell", inline: <<-SHELL
    set -e
    apt-get update
    groupadd -f sshusers
    useradd -m -s /bin/bash -G sshusers,sudo #{SSH_USER}
    mkdir -p /home/#{SSH_USER}/.ssh
    chmod 700 /home/#{SSH_USER}/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJ+DHkaXWSdamF2jik1rU/Qhj9jlH4sfJCnNkbHSvul y.boccuni@groupeonepoint.com" > /home/#{SSH_USER}/.ssh/authorized_keys
    chmod 644 /home/#{SSH_USER}/.ssh/authorized_keys
    chown -R #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}/
    echo "#{SSH_USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/#{SSH_USER}
  SHELL

end