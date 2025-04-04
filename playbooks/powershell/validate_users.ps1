param(
  [string[]]$Members
)

$ErrorActionPreference = "Stop"

Function Convert-FromSID($sid) {
  # Converts a SID to a Down-Level Logon name in the form of DOMAIN\UserName
  # If the SID is for a local user or group then DOMAIN would be the server
  # name.

  $account_object = New-Object System.Security.Principal.SecurityIdentifier($sid)
  try {
    $nt_account = $account_object.Translate([System.Security.Principal.NTAccount])
  }
  catch {
      throw $_
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
      throw $_
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
        $processed_members.Valid += $account_name
      }
    }
    Catch {
      $processed_members.Invalid += $m
    }
  }

  return $processed_members
}

$processed_members = Get-InputMember -Names $Members -IgnoreInvalid $true

$Ansible.Result["valid"] = $processed_members.Valid
$Ansible.Result["invalid"] = $processed_members.Invalid