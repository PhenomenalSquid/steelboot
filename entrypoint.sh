#!/bin/bash
#steelbot entrypoint
echo "steelboot is alive."

LOGFILE="/var/log/steelboot.log"

log() {
  local msg="[ $(date +%H:%M:%S) ] $1"
  echo -e "$msg" | tee -a "$LOGFILE"
}


log "steelboot is alive."

log "Running Ubuntu CIS hardening playbook..."
ansible-playbook /opt/steelboot/ansible/harden/ubuntu2204-cis.yml \
  -i localhost, \
  --connection=local \
  2>&1 | tee -a "$LOGFILE"

log "Playbook completed."
