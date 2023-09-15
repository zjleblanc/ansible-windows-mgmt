oauth_entity
=========

Role Variables
--------------

| Variable | Type | Value or Expression | Description |
| -------- | ------- | ------------------- | --------- |
| oauth_entity_configurations | default | [] |  |

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

  ```yaml
    - hosts: servers
      tasks:
        - name: Execute oauth_entity role
          ansible.builtin.include_role:
            name: oauth_entity
          vars:
            oauth_entity_configurations:
              - name: Oauth Entity
                client_id: "..."
                client_secret: "..."
              ...
  ```

License
-------

license (GPL-2.0-or-later, MIT, etc)

Author Information
-------
**Zachary LeBlanc**

Red Hat
