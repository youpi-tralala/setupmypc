#!/usr/bin/env bash
# 
set -euo pipefail

# Aller dans le dossier
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

source <(yq eval -o=shell '.' $SCRIPT_DIR/global_vars.yml)

echo "[create_vm] -- Prepare host"
ssh-keygen -f "/home/$SSH_USER/.ssh/known_hosts" -R "$VM_IP"
ansible-playbook -i localhost playbook_local.yml

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


echo "[create_vm] -- Attente que SSH soit disponible sur $VM_IP"

ansible localhost \
  -m wait_for \
  -a "host=$VM_IP port=22 timeout=120"

echo "[create_vm] -- Lancement du playbook Ansible"
ansible-playbook -i inventory.ini playbook_remote.yml"

echo "[create_vm] -- Mounting /home/$SSH_USER/ops from host to VM"
mount /home/$SSH_USER/mnt/ops_link/

echo "[create_vm] -- Terminé"
echo "VM IP : $VM_IP"