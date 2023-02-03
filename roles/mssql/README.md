mssql
=========

MSSQL installation and initial configuration for RHEL 8

Minimum Ansible Version: 2.1

Galaxy Tags: \[ mssql rhel8 database \]

Role Variables
--------------

| Variable | Default | Value or Expression |
| -------- | ------- | ------------------- |
| mssql_repo_url | ✅ | https://packages.microsoft.com/config/rhel/8/m ... |
| mssql_repo_name | ✅ | mssql-server |
| mssql_pid | ✅ | Developer |
| mssql_tcp_port | ✅ | 1433 |
| mssql_tools_include | ✅ | True |
| mssql_tools_repo_url | ✅ | https://packages.microsoft.com/config/rhel/8/prod.repo |
| mssql_tools_repo_name | ✅ | msprod |
| mssql_tools_users | ✅ | [] |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

  ```yaml
    - name: Setup MSSQL
      include_role: 
        name: mssql
      vars:
        mssql_sa_pwd: "{{ sa_password }}"
  ```

License
-------

license (GPL-2.0-or-later, MIT, etc)

Author Information
-------
**Zach LeBlanc**

Red Hat