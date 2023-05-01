# Install SQL Server Using DSC

Adapted from [role](https://github.com/kkolk/mssql) developed by @kkolk

Requirements:
- Active Directory domain controller
- AD administrator credentials

Objectives:
1. Install SQL Server dependencies
1. Create AD service accounts
1. Fetch installation media
1. Install SQL Server
1. Configure firewall
1. Configure SQL instance

## Tags

### prereqs

Install the required PowerShell modules and enable features required for running SQL Server.

### service_account

Create two service accounts for SQL Server instance:
1. SQL Service account
2. SQL Agent account

### fetch_media

Fetch the installation media for SQL Server and extract CABs to prep for DSC install. For testing purposes, an evaluation license will suffice.

### install

Apply the DSC configuration and wait... this step can take awhile depending on your server specs.

### configure

Configure the server firewall to enable remote access to the SQL Server instance. Additionally, configure the SQL Server instance itself.
<br>
Either group of steps can be run individually with `configure_firewall` or `configure_sql`.

## handlers

A couple of handlers exist to support the installation process.

1. reboot windows
2. restart the SQL Agent service

## example vars file

The playbook references `{{ playbook_dir }}\local_vars\mssql_vars.yml`. An example of the configuration I tested with can be found [here](./files/mssql_vars.yml).