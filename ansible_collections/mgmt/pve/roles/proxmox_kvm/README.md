mgmt.pve.proxmox_kvm
=========

Provision a guest in Proxmox VE using the provided configuration object.

Galaxy Tags: \[ proxmox kvm provision \]

Expected Credential
------------------

Injector Config<br>
```
extra_vars:
  proxmox_api_host: '{{ pve_api_host }}'
  proxmox_api_user: '{{ pve_api_user }}'
  proxmox_api_password: '{{ pve_api_password }}'
  proxmox_api_token_id: '{{ pve_api_token_id }}'
  proxmox_api_token_secret: '{{ pve_api_token_secret }}'
```

Required Variables
------------------

| Name | Example | Description |
| -------- | ------- | ------------------- |
| pve_config | `{ ... }` | PVE configuration object |


Role Variables
--------------

| Variable | Type | Value or Expression | Description |
| -------- | ------- | ------------------- | --------- |
| proxmox_api_base_url | default | https://{{ proxmox_api_host }}:8006/api2/json |  |
| proxmox_kvm_domain | default | autodotes.local |  |

Example Playbook
---------------- 

  ```yaml
    - hosts: localhost
      tasks:
        - name: Execute proxmox_kvm role
          ansible.builtin.include_role:
            name: mgmt.pve.proxmox_kvm
          vars:
            pve_config:
              cores: 2
              cpu: host
              description: KVM guest created from template
              ide:
                ide2: none,media=cdrom
              kvm: "{{ qcows.rhel7 }}"
              memory: 8192
              name: rhel-guest-1
              net: 
                net0: virtio,bridge=vmbr0,firewall=1
              node: pve
              onboot: true
              ostype: l26
              virtio:
                virtio0: local:32,format=qcow2
              scsihw: virtio-scsi-single
              sockets: 2
              tags:
                - demo
                - rhel
                - linux
              timeout: 120
  ```

License
-------

license (GPL-2.0-or-later, MIT, etc)

Author Information
-------
**Zachary LeBlanc**
