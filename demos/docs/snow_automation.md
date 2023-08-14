# ServiceNow Integration with Ansible

Objectives:
1. Create an Application in Ansible Automation Platform (AAP)
1. Disable Business Rules that prevent automated inserts
1. Create OAuth resources in Service Now
1. Add AAP certificate to Service Now Trusted Store
1. Create API resoures in Service Now
1. Create Catalog Item in Service Now

## Playbook

[Snow Automation](../proxmox_kvm_clone.yml)

### Pre-reqs

- Create a Service Now developer instance (free!) or have credentials to an existing instance handy
- Create a Job Template in AAP you want to launch when a Catalog Item is ordered
- Install `servicenow.itsm` collection

### Environment Variables

| Name | Example | Required |
| --- | --- | :---: |
| SN_HOST | https://dev29577.service-now.com/ | YES |
| SN_USERNAME | admin | YES |
| SN_PASSWORD | s3cr3t | YES |
| CONTROLLER_HOST | https://controller.example.com | YES |

#### Extra Variables

| Name | Default | Required |
| --- | --- | :---: |
| snow_app_name | `ServiceNow App ({{ snow_instance }})` | |
| snow_oauth_entity_name | `Ansible Controller OAuth` | |
| snow_oauth_profile_name | `Ansible Controller Write Profile` | |
| controller_org | `3` (id in AAP) | YES |

## Service Now Workflow

### Setup

1. Create a Workflow in Service Now
1. Add a Run Script activity between the 'Begin' and 'End' nodes
1. Copy the script below into the Run Script activity configuration
1. Tweak the variables as needed for your downstream job template
1. Anything in the `current.variables` object must also be added/updated in the upstream Catalog Item
1. Set the job_id value to the job template in your AAP instance to be launched

### Workflow Script
```js
try { 
	var r = new sn_ws.RESTMessageV2('Ansible Automation Platform', 'Launch Ansible Job Template');
	r.setStringParameterNoEscape('decomm_cat_item', current.cat_item);
	r.setStringParameterNoEscape('decomm_ritm', current.number);
	r.setStringParameterNoEscape('decomm_sys_id', current.sys_id);
	r.setStringParameterNoEscape('decomm_message', current.variables.decomm_message);
	r.setStringParameterNoEscape('decomm_requested_for', current.requested_for);
	r.setStringParameterNoEscape('decomm_host', current.variables.decomm_host);
	r.setStringParameterNoEscape('job_id', 45);
	
	var response = r.execute();
	var responseBody = response.getBody();
	var httpStatus = response.getStatusCode();
}
catch(ex) {
	var message = ex.message;
}
```

## Service Now Rest Message

1. The REST message created is setup to pass specific variables to a Job Template
1. Navigate to the REST message and inspect the Content with variables denoted by `${var_name}`
1. Ensure any changes to the Workflow Script map to the REST message content and are handled by the Job Template as extra vars

### Initial Variable Mapping

| REST Content / Workflow Script | Job Template |
| --- | --- |
| job_id | _used in request URL_ |
| decomm_host | _hosts |
| decomm_message | _msg |
| decomm_ritm | ritm |
| decomm_cat_item | cat_item |
| decomm_requested_for | requested_for |
| decomm_sys_id | sys_id |

## Service Now Catalog Item

The Catalog Item is created via the playbook, but will require some manual steps to properly connect it to your workflow. 

### Process Engine

1. Navigate to the Catalog Item in your Service Now instance
1. In the editable view, select the Process Engine tab
1. Set the value to point at your workflow