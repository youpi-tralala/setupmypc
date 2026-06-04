# Get global variables
require 'yaml'
GLOBAL_VARS = YAML.load_file(File.expand_path('../global_vars.yml', __FILE__))

VM_NAME             = GLOBAL_VARS.fetch('VM_NAME')
SSH_USER            = GLOBAL_VARS.fetch('SSH_USER')
WINDOWS_SSH_DIR     = GLOBAL_VARS.fetch('WINDOWS_SSH_DIR')
WINDOWS_WORKING_DIR = GLOBAL_VARS.fetch('WINDOWS_WORKING_DIR')

  # Basic configuration
Vagrant.configure('2') do |config|
  config.vm.box = 'debian/bookworm64'

  config.vm.hostname = VM_NAME
  config.vm.define VM_NAME

  # Windows synced folders
  #config.vm.synced_folder WINDOWS_WORKING_DIR,"/home/#{SSH_USER}/ops",owner: SSH_USER,group: SSH_USER
  #config.vm.synced_folder WINDOWS_SSH_DIR,"/home/#{SSH_USER}/.ssh",owner: SSH_USER,group: SSH_USER, type: "rsync", rsync__auto: true
  # Disable default vagrant synced folder as it is already in ops
  config.vm.synced_folder '.', '/vagrant', disabled: true

  # Host‑Only network
  config.vm.network 'private_network', ip: '192.168.56.10'

  # resource allocation
  config.vm.provider 'virtualbox' do |vb|
    vb.name   = VM_NAME
    vb.memory = 8192
    vb.cpus   = 4
  end

  # Provisioning
  config.vm.provision 'shell', inline: <<-SHELL
    set -e
    groupadd -f sshusers

    if ! id #{SSH_USER} >/dev/null 2>&1; then
      useradd -m -s /bin/bash -G sshusers,sudo #{SSH_USER}
    fi

    mkdir -p /home/#{SSH_USER}/.ssh
    chmod 700 /home/#{SSH_USER}/.ssh

    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJ+DHkaXWSdamF2jik1rU/Qhj9jlH4sfJCnNkbHSvul y.boccuni@groupeonepoint.com" \
      > /home/#{SSH_USER}/.ssh/authorized_keys
    chmod 600 /home/#{SSH_USER}/.ssh/authorized_keys

    for i in $(grep -ril private /home/#{SSH_USER}/.ssh/*); do chmod 600 $i; done
    for i in /home/#{SSH_USER}/.ssh/*.pub; do chmod 644 $i; done

    chown -R #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}

    echo "#{SSH_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/#{SSH_USER}
  SHELL
end