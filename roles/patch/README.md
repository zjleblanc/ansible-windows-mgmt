patch
=========

A role to apply updates to a Windows server

Requirements
------------

pywinrm

Role Variables
--------------

| Variable | Default |
| --- | --- |
| patch_categories | \['SecurityUpdates', 'CriticalUpdates', 'UpdateRollups'\] |
| patch_kbs | \[ \] |
| patch_failed_report | true |
| patch_failed_report_dest | C:\\ansible_failed_updates.txt |

Example Playbook
----------------
```yaml
  - name: Patch server
    include_role: patch

  - name: Patch server (turn off reporting)
    include_role: patch
    vars:
      patch_failed_report: false

  - name: Patch server (specific patch)
    include_role: patch
    vars:
      patch_categories:
        - SecurityUpdates
      patch_kbs:
        - KB4056892
        - KB4073117
```

License
-------

BSD
