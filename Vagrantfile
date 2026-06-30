# Variables globales chargées depuis global_vars.yml
require 'yaml'
GLOBAL_VARS = YAML.load_file(File.expand_path('../global_vars.yml', __FILE__))

VM_NAME         = GLOBAL_VARS.fetch('VM_NAME')
SSH_USER        = GLOBAL_VARS.fetch('SSH_USER')
SSH_USER_UID    = GLOBAL_VARS.fetch('SSH_USER_UID')
SSH_USER_GID    = GLOBAL_VARS.fetch('SSH_USER_GID')
WINDOWS_SSH_DIR = GLOBAL_VARS.fetch('WINDOWS_SSH_DIR')
WINDOWS_WORKING_DIR = GLOBAL_VARS.fetch('WINDOWS_WORKING_DIR')
VM_IP           = GLOBAL_VARS.fetch('VM_IP')

Vagrant.configure('2') do |config|

  # Box Debian 12 (Bookworm) — stable
  config.vm.box = 'debian/bookworm64'
  config.vm.hostname = VM_NAME
  config.vm.define VM_NAME

  # Ressources allouées à la VM
  config.vm.provider 'virtualbox' do |vb|
    vb.name   = VM_NAME
    vb.memory = 4096
    vb.cpus   = 2
  end

  # Réseau host-only : accès SSH depuis le host sans NAT
  config.vm.network 'private_network', ip: VM_IP

  # Dossier de travail principal — monté depuis Windows, édité dans la VM
  # type virtualbox = bidirectionnel, fichiers physiquement sur Windows (NTFS)
  # owner/group résolus depuis le username après vagrant reload (voir run.sh)
  # dmode/fmode = permissions appliquées au montage (NTFS ne supporte pas les bits POSIX)
  config.vm.synced_folder WINDOWS_WORKING_DIR, "/home/#{SSH_USER}/ops",
    mount_options: [
      "uid=#{SSH_USER_UID}",
      "gid=#{SSH_USER_GID}",
      "dmode=755",
      "fmode=644"
    ]

  # Dossier .ssh — clés SSH stockées sur Windows, accessibles dans la VM
  # fmode=600 requis par le client SSH (clé privée non lisible par les autres)
  config.vm.synced_folder WINDOWS_SSH_DIR, "/home/#{SSH_USER}/.ssh",
    mount_options: [
      "uid=#{SSH_USER_UID}",
      "gid=#{SSH_USER_GID}",
      "dmode=700",
      "fmode=600"
    ]

  # Provisioning shell — exécuté une seule fois à la création de la VM
  config.vm.provision 'shell', inline: <<-SHELL
    set -e

    # Création du groupe sshusers si inexistant
    groupadd -f sshusers

    # vboxsf est créé par les Guest Additions — on s'assure qu'il existe
    groupadd -f vboxsf

    # Création du user avec UID/GID fixes pour cohérence avec les montages VirtualBox
    # vboxsf = groupe requis pour accéder aux dossiers partagés VirtualBox
    if ! id #{SSH_USER} &>/dev/null; then
      groupadd -g #{SSH_USER_GID} #{SSH_USER}
      useradd -m -u #{SSH_USER_UID} -g #{SSH_USER_GID} -s /bin/bash -G sshusers,sudo,vboxsf #{SSH_USER}
    fi

    # Clé publique SSH autorisée pour connexion sans mot de passe
    mkdir -p /home/#{SSH_USER}/.ssh
    chmod 700 /home/#{SSH_USER}/.ssh
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFJ+DHkaXWSdamF2jik1rU/Qhj9jlH4sfJCnNkbHSvul y.boccuni@groupeonepoint.com" \
      > /home/#{SSH_USER}/.ssh/authorized_keys
    chmod 600 /home/#{SSH_USER}/.ssh/authorized_keys

    chown -R #{SSH_USER}:#{SSH_USER} /home/#{SSH_USER}

    # Sudo sans mot de passe
    echo "#{SSH_USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/#{SSH_USER}
  SHELL

end