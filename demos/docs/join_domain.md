# Join Windows Server to Domain

Requirements:
- Active Directory domain controller
- [Windows Domain Admin](https://docs.autodotes.com/Ansible/Credential%20Types/microsoft_ad_admin/) custom credential

Objectives:
1. Configure DNS settings
1. Join to domain
1. Reboot server
1. Update inventory host vars

## Playbook

[join_domain.yml](../join_domain.yml)

1. Uses a [Windows Domain Admin](https://docs.autodotes.com/Ansible/Credential%20Types/microsoft_ad_admin/) custom credential type to pass in credentials
2. Configure the domain controller dns entry<br>
    `domain_controller: <inventory hostname of your domain controller>`
    ```yaml
    - name: Configure name servers
        ansible.builtin.win_shell: |
        Set-DnsClientServerAddress \
            -InterfaceIndex 6 \
            -ServerAddresses ("{{ hostvars[domain_controller]['ansible_host'] }}","192.168.0.1")
    ```
3. Join the domain and update inventory
