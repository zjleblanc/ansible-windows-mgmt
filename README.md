# ansible-windows-mgmt

Ansible repository for content used to manage Windows servers


## Roles

| FCQN | Description | Docs |
| --- | --- | :---: |
| `mgmt.snow_configuration.records` | Wrap the Service Now Table API module to be **idempotent** | [📖](./collections/ansible_collections/mgmt/snow_configuration/roles/records/README.md) |
| `mgmt.windows.mssql` | This role installs PowerShell requirements and adds Windows features required  for SQL Server before completing an installation of a SQL Server instance using  desired state configuration | [📖](./collections/ansible_collections/mgmt/windows/roles/mssql/README.md) |
| `mgmt.windows.patch` | Apply updates to a Windows server| [📖](./collections/ansible_collections/mgmt/windows/roles/patch/README.md) |
| `mgmt.pve.proxmox_kvm` | Provision a Proxmox KVM| [📖](./collections/ansible_collections/mgmt/pve/roles/proxmox_kvm/README.md) |

## Demos

| Name | Description | Docs |
| --- | --- | :---: |
| Proxmox: Clones VMs from template | Clone a VM and create one or more copies | [📖](./demos/proxmox_kvm_clone.yml) |
| Service Now: Trigger Ansible via Catalog Item | Create a Catalog Item in Service Now to launch an Ansible job | [📖](./demos/docs/snow_automation.md) |
| Windows: Setup WinRM | Setup WinRM on Windows host for Ansible automation | [📖](./demos/docs/setup_winrm.md) |
| Windows: Join Domain | Join Windows host to Active Directory Domain | [📖](./demos/docs/join_domain.md) |
| Windows: Patch servers | Beginner level patching implementation | [📖](./demos/patch.yml) |
| Windows: Delete Long Folder Paths | Delete folders on Windows servers with long file paths exceeding the default limit | [📖](./demos/docs/delete_long_paths.md) |
| Windows: Install SQL Server using DSC | Install Microsoft SQL Server on a Windows host using Desired State Configuration (DSC) | [📖](./demos/docs/install_mssql_dsc.md) |