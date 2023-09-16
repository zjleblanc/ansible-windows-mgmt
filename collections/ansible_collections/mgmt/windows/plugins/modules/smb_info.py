#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright: (c) 2012, Michael DeHaan <michael.dehaan@gmail.com>, and others
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

DOCUMENTATION = r'''
---
module: smb_info
short_description: Gather information regarding server message block shares
description:
  - Gets list of server message block shares on a Windows hosts
  - Gets access details for each share
options:
  name:
    description:
      - Optional name filter to isolate specific shares
    type: str
    default: *
seealso:
- module: ansible.windows.win_share
author:
- Zach LeBlanc (@zjleblanc)
'''

EXAMPLES = r'''
- name: Get info for all server message block shares
  mgmt.windows.smb_info:

- name: Get info for shares staring with Net
  mgmt.windows.smb_info:
    name: Net*
'''

RETURN = r'''
info:
    description: Object containing entries for each server message block share identified with metadata and access details
    returned: success
    type: dict
'''