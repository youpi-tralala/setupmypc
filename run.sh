#!/usr/bin/env bash
# 
set -euo pipefail

# Aller dans le dossier
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

source <(yq eval -o=shell '.' $SCRIPT_DIR/global_vars.yml)

echo "[create_vm] -- Prepare host"
ssh-keygen -f "/home/$SSH_USER/.ssh/known_hosts" -R "$VM_IP"
ansible-playbook -i localhost $SCRIPT_DIR/playbook_local.yml

echo "[create_vm] -- Démarrage de la VM via VirtualBox"
vagrant up --provider=virtualbox

echo "[create_vm] -- Génération du fichier ssh/config.d/vagrant_$VM_NAME"
cat << EOF > ~/.ssh/config.d/vagrant_"$VM_NAME" 
Host $VM_NAME
    HostName $VM_IP
    User $SSH_USER
    IdentityFile $SSH_USER_PRIVATE_KEY_PATH
    IdentitiesOnly yes
    StrictHostKeyChecking no
EOF

echo "[create_vm] -- Génération du fichier inventory.ini"
cat << EOF > $SCRIPT_DIR/inventory.ini
[all:vars]
ansible_user=$SSH_USER
ansible_ssh_private_key_file=$SSH_USER_PRIVATE_KEY_PATH
ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[ALL]
$VM_NAME ansible_host=$VM_IP 
EOF

echo "[create_vm] -- Lancement du playbook Ansible"
ansible-playbook -i $SCRIPT_DIR/inventory.ini $SCRIPT_DIR/playbook_remote.yml

echo "[create_vm] -- Synciing folders with unison"
unison home -auto

echo "[create_vm] -- Terminé"
echo "VM IP : $VM_IP"