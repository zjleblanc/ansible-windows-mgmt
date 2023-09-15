#!powershell

# Copyright: (c) 2017, Ansible Project
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
    options = @{
        name = @{ type = 'str'; required = $false; default = '*' }
    }
    supports_check_mode = $false
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$name = $module.Params.name

$module.Result.info = @{}
$module.Result.changed = $false

$info = @{}
$shares = Get-SmbShare -Name $name

$shares | ForEach-Object {
  $info.add($_.Name, @{})
  $info[$_.Name].add("metadata", $_)

  $access = Get-SmbShareAccess -Name $_.Name
  $info[$_.Name].add("access", $access)
}

$module.Result.info = $info
$module.ExitJson()