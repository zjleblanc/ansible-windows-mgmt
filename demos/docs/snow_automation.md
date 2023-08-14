# ServiceNow Integration with Ansible

## Workflow Script
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