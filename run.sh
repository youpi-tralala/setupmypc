#!/usr/bin/env bash
# 
set -euo pipefail

# Go to script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Load global variables
source <(yq eval -o=shell '.' $SCRIPT_DIR/global_vars.yml)

echo " --------> Prepare host"
ssh-keygen -f "/home/$SSH_USER/.ssh/known_hosts" -R "$VM_IP"
ansible-playbook playbook_host.yml

echo " --------> Create VM with Vagrantfile"
vagrant up --provider=virtualbox 

echo " --------> Wait for SSH to be ready on $VM_NAME ($VM_IP)"
ansible localhost \
  -m wait_for \
  -a "host=$VM_IP port=22 timeout=120"

echo " --------> Provision VM with Ansible playbook"
ansible-playbook -i inventory.ini playbook_remote.yml

echo " --------> Done"
echo "VM IP : $VM_IP"