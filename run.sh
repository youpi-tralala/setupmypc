#!/usr/bin/env bash
# 
set -euo pipefail

# Aller dans le dossier
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

source <(yq eval -o=shell '.' $SCRIPT_DIR/global_vars.yml)

echo "[create_vm] -- Démarrage de la VM via VirtualBox"
vagrant up --provider=virtualbox

#echo "[create_vm] -- Récupération de l'IP de la VM"
#VM_IP=$(vagrant ssh -- bash -lc [[ "$(ip -4 addr show enp0s8)" ]] && NIC=enp0s8 || NIC=enp0s3 ; ip -4 addr show $NIC | awk '/inet /{print $2}' | cut -d/ -f1)
VM_IP=$VM_IP

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
ansible-playbook -i $SCRIPT_DIR/inventory.ini $SCRIPT_DIR/playbook.yml

echo "[create_vm] -- Terminé"
echo "VM IP : $VM_IP"