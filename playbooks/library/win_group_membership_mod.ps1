#!powershell

# Copyright: (c) 2017, Andrew Saraceni <andrew.saraceni@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

Function Convert-FromSID($sid, $ignore_invalid=$false) {
    # Converts a SID to a Down-Level Logon name in the form of DOMAIN\UserName
    # If the SID is for a local user or group then DOMAIN would be the server
    # name.

    $account_object = New-Object System.Security.Principal.SecurityIdentifier($sid)
    try {
        $nt_account = $account_object.Translate([System.Security.Principal.NTAccount])
    }
    catch {
        if($ignore_invalid) {
            throw $_
        } else {
            Fail-Json -obj @{} -message "failed to convert sid '$sid' to a logon name: $($_.Exception.Message)"
        }
    }

    return $nt_account.Value
}

Function Convert-ToSID {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingEmptyCatchBlock", "",
        Justification = "We don't care if converting to a SID fails, just that it failed or not")]
    param($account_name, $ignore_invalid=$false)
    # Converts an account name to a SID, it can take in the following forms
    # SID: Will just return the SID value that was passed in
    # UPN:
    #   principal@domain (Domain users only)
    # Down-Level Login Name
    #   DOMAIN\principal (Domain)
    #   SERVERNAME\principal (Local)
    #   .\principal (Local)
    #   NT AUTHORITY\SYSTEM (Local Service Accounts)
    # Login Name
    #   principal (Local/Local Service Accounts)

    try {
        $sid = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $account_name
        return $sid.Value
    }
    catch {}

    if ($account_name -like "*\*") {
        $account_name_split = $account_name -split "\\"
        if ($account_name_split[0] -eq ".") {
            $domain = $env:COMPUTERNAME
        }
        else {
            $domain = $account_name_split[0]
        }
        $username = $account_name_split[1]
    }
    else {
        $domain = $null
        $username = $account_name
    }

    if ($domain) {
        # searching for a local group with the servername prefixed will fail,
        # need to check for this situation and only use NTAccount(String)
        if ($domain -eq $env:COMPUTERNAME) {
            $adsi = [ADSI]("WinNT://$env:COMPUTERNAME,computer")
            $group = $adsi.psbase.children | Where-Object { $_.schemaClassName -eq "group" -and $_.Name -eq $username }
        }
        else {
            $group = $null
        }
        if ($group) {
            $account = New-Object System.Security.Principal.NTAccount($username)
        }
        else {
            $account = New-Object System.Security.Principal.NTAccount($domain, $username)
        }
    }
    else {
        # when in a domain NTAccount(String) will favour domain lookups check
        # if username is a local user and explicitly search on the localhost for
        # that account
        $adsi = [ADSI]("WinNT://$env:COMPUTERNAME,computer")
        $user = $adsi.psbase.children | Where-Object { $_.schemaClassName -eq "user" -and $_.Name -eq $username }
        if ($user) {
            $account = New-Object System.Security.Principal.NTAccount($env:COMPUTERNAME, $username)
        }
        else {
            $account = New-Object System.Security.Principal.NTAccount($username)
        }
    }

    try {
        $account_sid = $account.Translate([System.Security.Principal.SecurityIdentifier])
    }
    catch {
        if($ignore_invalid) {
            throw $_
        } else {
            Fail-Json @{} "account_name $account_name is not a valid account, cannot get SID: $($_.Exception.Message)"
        }
    }

    return $account_sid.Value
}

Function Get-InputMember {
    <#
    .SYNOPSIS
    Converts the input member list to a unique list of accounts and their SIDs.
    .PARAMETER Names
    The input list of member names.
    .PARAMETER IgnoreInvalid
    Flag to ignore invalid member names.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Names,
        [Parameter(Mandatory)]
        [bool]$IgnoreInvalid
    )

    $unique_sids = [System.Collections.Generic.HashSet[string]]@()
    
    $processed_members = @{
        Valid = @()
        Invalid = @()
    }

    foreach ($m in $Names) {
        Try {
            $sid = Convert-ToSID -account_name $m -ignore_invalid $ignore_invalid
            if ($unique_sids.Add($sid)) {
                $account_name = Convert-FromSID -sid $sid -ignore_invalid $ignore_invalid
                $processed_members.Valid += @{
                    sid = $sid
                    account_name = $account_name
                }
            }
        }
        Catch {
            if(!$ignore_invalid) {
                throw $_
            }
            $processed_members.Invalid += $m
        }
    }

    return $processed_members
}

function Get-GroupMember {
    <#
    .SYNOPSIS
    Retrieve group members for a given group, and return in a common format.
    .NOTES
    Returns an array of hashtables of the same type as returned from Test-GroupMember.
    #>
    param(
        [System.DirectoryServices.DirectoryEntry]$Group
    )

    # instead of using ForEach pipeline we use a standard loop and cast the
    # object to the ADSI adapter type before using it to get the SID and path
    # this solves an random issue where multiple casts could fail once the raw
    # object is invoked at least once
    $raw_members = $Group.psbase.Invoke("Members")
    $current_members = [System.Collections.ArrayList]@()
    foreach ($raw_member in $raw_members) {
        $raw_member = [ADSI]$raw_member
        $sid_bytes = $raw_member.InvokeGet("objectSID")
        $ads_path = $raw_member.InvokeGet("ADsPath")
        $member_info = @{
            sid = New-Object -TypeName System.Security.Principal.SecurityIdentifier -ArgumentList $sid_bytes, 0
            adspath = $ads_path
        }
        $current_members.Add($member_info) > $null
    }

    $members = @()
    foreach ($current_member in $current_members) {
        $parsed_member = @{
            sid = $current_member.sid
            account_name = $null
        }

        $rootless_adspath = $current_member.adspath.Replace("WinNT://", "")
        $split_adspath = $rootless_adspath.Split("/")

        # Ignore lookup on a broken SID, and just return the SID as the account_name
        if ($split_adspath.Count -eq 1 -and $split_adspath[0] -like "S-1*") {
            $parsed_member.account_name = $split_adspath[0]
        }
        else {
            $account_name = Convert-FromSID -sid $current_member.sid
            $parsed_member.account_name = $account_name
        }

        $members += $parsed_member
    }

    return $members
}

$params = Parse-Args $args -supports_check_mode $true
$check_mode = Get-AnsibleParam -obj $params -name "_ansible_check_mode" -type "bool" -default $false

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true
$members = Get-AnsibleParam -obj $params -name "members" -type "list" -failifempty $true
$ignore_invalid = Get-AnsibleParam -obj $params -name "ignore_invalid" -type "bool" -default $false
$state = Get-AnsibleParam -obj $params -name "state" -type "str" -default "present" -validateset "present", "absent", "pure"

$result = @{
    changed = $false
    name = $name
}
if ($state -in @("present", "pure")) {
    $result.added = @()
}
if ($state -in @("absent", "pure")) {
    $result.removed = @()
}
if ($ignore_invalid) {
    $result.invalid = @()
}

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$group = $adsi.Children | Where-Object { $_.SchemaClassName -eq "group" -and $_.Name -eq $name }

if (!$group) {
    Fail-Json -obj $result -message "Could not find local group $name"
}

$processed_members = Get-InputMember -Names $members -IgnoreInvalid $ignore_invalid
$current_members = Get-GroupMember -Group $group
$pure_members = @()

if ($ignore_invalid) {
    $result.invalid = $processed_members.Invalid
}

foreach ($member in $processed_members.Valid) {
    if ($state -eq "pure") {
        $pure_members += $member
    }

    $user_in_group = $false
    foreach ($current_member in $current_members) {
        if ($current_member.sid -eq $member.sid) {
            $user_in_group = $true
            break
        }
    }

    $member_sid = "WinNT://{0}" -f $member.sid

    try {
        if ($state -in @("present", "pure") -and !$user_in_group) {
            if (!$check_mode) {
                $group.Add($member_sid)
            }
            $result.added += $member.account_name
            $result.changed = $true
        }
        elseif ($state -eq "absent" -and $user_in_group) {
            if (!$check_mode) {
                $group.Remove($member_sid)
            }
            $result.removed += $member.account_name
            $result.changed = $true
        }
    }
    catch {
        Fail-Json -obj $result -message $_.Exception.Message
    }
}

if ($state -eq "pure") {
    # Perform removals for existing group members not defined in $members
    $current_members = Get-GroupMember -Group $group

    foreach ($current_member in $current_members) {
        $user_to_remove = $true
        foreach ($pure_member in $pure_members) {
            if ($pure_member.sid -eq $current_member.sid) {
                $user_to_remove = $false
                break
            }
        }

        $member_sid = "WinNT://{0}" -f $current_member.sid

        try {
            if ($user_to_remove) {
                if (!$check_mode) {
                    $group.Remove($member_sid)
                }
                $result.removed += $current_member.account_name
                $result.changed = $true
            }
        }
        catch {
            Fail-Json -obj $result -message $_.Exception.Message
        }
    }
}

$final_members = Get-GroupMember -Group $group

if ($final_members) {
    $result.members = [Array]$final_members.account_name
}
else {
    $result.members = @()
}

if ($check_mode) {
    if ($result.added.count -gt 0) {
        $result.members += $result.added
    }
    if ($result.removed.count -gt 0) {
        $result.members = $result.members | Where-Object { $_ -notin $result.removed }
    }
}

Exit-Json -obj $result