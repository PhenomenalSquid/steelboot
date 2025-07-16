#!/bin/bash
#steelbot entrypoint
echo "steelboot is alive."

LOGFILE="/var/log/steelboot.log"

log() {
  local msg="[ $(date +%H:%M:%S) ] $1"
  echo -e "$msg" | tee -a "$LOGFILE"
}

log "steelboot is alive."

# Run Ansible playbook
if ! ansible-playbook /opt/steelboot/ansible/harden/ubuntu2204-cis.yml \
  -i localhost, \
  --connection=local \
  2>&1 | tee -a "$LOGFILE"; then
  log "Error: Ansible playbook execution failed"
  exit 1
fi

log "Playbook completed."