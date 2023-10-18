# ansible-windows-mgmt

Ansible repository for content used to manage Windows servers

## Playbooks
- [patching.yml](./playbooks/patching.yml)

## Roles
- [mssql](./roles/mssql/README.md)<br>This role installs PowerShell requirements and adds Windows features required  for SQL Server before completing an installation of a SQL Server instance using  desired state configuration.
- [patch](./roles/patch/README.md)<br>Apply updates to a Windows server

## Demos
- [Proxmox: Clones VMs from template](./demos/proxmox_kvm_clone.yml)<br>Clone a VM and create one or more copies
- [Service Now: Trigger Ansible via Catalog Item](./demos/docs/snow_automation.md)<br>Create a Catalog Item in Service Now to launch an Ansible job
- [Windows: Setup WinRM](./demos/docs/setup_winrm.md)<br>Setup WinRM on Windows host for Ansible automation
- [Windows: Join Domain](./demos/docs/join_domain.md)<br>Join Windows host to Active Directory Domain
- [Windows: Patch servers](./demos/patch.yml)<br>Beginner Level Implementation
- [Windows: Delete Long Folder Paths](./demos/docs/delete_long_paths.md)<br>Delete folders on Windows servers with long file paths exceeding the default limit
- [Windows: Install SQL Server using DSC](./demos/docs/install_mssql_dsc.md)<br>Install Microsoft SQL Server on a Windows host using Desired State Configuration (DSC)