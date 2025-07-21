#!/bin/bash
#steelbot entrypoint
echo "steelboot is alive."

LOGFILE="/mnt/var/log/steelboot.log"

log() {
  local msg="[ $(date +%H:%M:%S) ] $1"
  echo -e "$msg" | tee -a "$LOGFILE"
}

log "steelboot is alive."

# Copy ansible to host and run in chroot
cp -r /opt/steelboot/ansible /mnt/tmp/steelboot-ansible
log "Running ansible playbook in chroot to apply changes to host system"

# Ensure DNS resolution works in chroot
cp /mnt/etc/resolv.conf /mnt/etc/resolv.conf.steelboot-backup 2>/dev/null || true
cp /etc/resolv.conf /mnt/etc/resolv.conf 2>/dev/null || true

# Run Ansible playbook in chroot so it targets the host filesystem  
if ! chroot /mnt ansible-playbook /tmp/steelboot-ansible/steelboot-playbook.yml \
  -i localhost, \
  --connection=local \
  --skip-tags aide,aide_build_database,aide_check_audit_tools,aide_periodic_cron_checking,package_aide_installed \
  2>&1 | tee -a "$LOGFILE"; then
  log "Error: Ansible playbook execution failed"
  rm -rf /mnt/tmp/steelboot-ansible
  exit 1
fi

# Restore original resolv.conf and cleanup
cp /mnt/etc/resolv.conf.steelboot-backup /mnt/etc/resolv.conf 2>/dev/null || true
rm -f /mnt/etc/resolv.conf.steelboot-backup
rm -rf /mnt/tmp/steelboot-ansible

log "Playbook completed."