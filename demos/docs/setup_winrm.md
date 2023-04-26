# Setup WinRM Using Ansible

Objectives:
1. Provision windows instances (on Proxmox)
1. Configure winrm on windows instances using psexec and add to inventory
1. Gather facts about new hosts to populate Controller view

## Playbooks

### proxmox_kvm_clone.yml

[Playbook](../proxmox_kvm_clone.yml)

Uses a proxmox custom credential type to pass in API credentials:
- proxmox_api_host
- proxmox_api_user
- proxmox_api_token_id
- proxmox_api_token_secret

Executs proxmox_kvm role to create new instances based on provided configs:
```yaml
---
# example
proxmox_ve_configs:
  - agent: true
    clone: win11-admin-server-template
    full: false
    name: win11-guest-1
    node: pve
    tags:
      - ansible
      - windows
      - yaml-config
```

Retrieves the ip for newly created instance (requires agent: true) and adds to "needs_winrm" group in inventory

### setup_winrm.yml

[Playbook](../setup_winrm.yml)

Executes a powershell script to configure winrm for ansible on each host in the "needs_winrm" group.

Adds the host to a "windows" group and removes the host from "needs_winrm" group upon success.

### win_facts.yml

[Playbook](../../playbooks/win_facts.yml)

Gathers facts about all hosts in the windows group - must pass limit "windows" to focus on the recently added hosts.

Enable fact storage on the job template and ensure your per-host ansible fact cahce timeout in Job Settings is not set to "0" in order to populate the host facts view in the Controller UI.