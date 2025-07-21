#!/bin/bash
#steelbot entrypoint
echo "steelboot is alive."

LOGFILE="/mnt/var/log/steelboot.log"

log() {
  local msg="[ $(date +%H:%M:%S) ] $1"
  echo -e "$msg" | tee -a "$LOGFILE"
}

log "steelboot is alive."

# Copy ansible to host filesystem  
cp -r /opt/steelboot/ansible /mnt/tmp/steelboot-ansible
log "Running ansible playbook with nsenter to access host systemd"

# Ensure DNS resolution works
cp /mnt/etc/resolv.conf /mnt/etc/resolv.conf.steelboot-backup 2>/dev/null || true
cp /etc/resolv.conf /mnt/etc/resolv.conf 2>/dev/null || true

# Run Ansible playbook in chroot (working directory and relative paths fixed)
if ! chroot /mnt bash -c "cd /tmp/steelboot-ansible && ANSIBLE_STDOUT_CALLBACK=default ansible-playbook steelboot-playbook.yml \
  -i localhost, \
  --connection=local \
  --skip-tags aide,aide_build_database,aide_check_audit_tools,aide_periodic_cron_checking,package_aide_installed,service" \
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
log "NOTE: Service configurations updated but not restarted. Reboot system or manually restart services to apply all changes."
log "NOTE: Original /etc/hosts backed up to /etc/hosts.steelboot-backup"