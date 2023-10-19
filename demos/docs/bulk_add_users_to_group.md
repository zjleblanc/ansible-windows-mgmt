# Bulk Add Users to AD Group

Requirements:
- Active Directory domain controller
- AD administrator credentials
- List of AD Users
- Target AD Group

Objectives:
1. Retrieve users within a directory subtree
1. Cross-check input list against existing users
1. Add valid input users to target group
1. Report on invalid input users (those that do not exist in the subtree)

## Playbook

[bulk_add_users_to_group.yml](../bulk_add_users_to_group.yml)

1. Uses a [Windows Domain Admin](https://docs.autodotes.com/Ansible/Credential%20Types/microsoft_ad_admin/) custom credential type to pass in credentials.
1. Get all domain users within subtree, specified by `{{ search_root }}`. By default, only pulls the **samAccountName** property, but others can be added to module param **properties**.
1. Do a list intersection between input and previous result - these are your valid input users.
1. Do a list difference between input and previous result - these are you invalid input users.
1. Add the valid list of users to target group specified by `{{ target_group }}`.
1. Print list of invalid input users. Recommend extending this to a report, notification, etc.
