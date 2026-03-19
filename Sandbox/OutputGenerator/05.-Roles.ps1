# Generates examples with output for Roles wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

# Get system_user role
$role = Get-MMRole -Name 'system_user'
$ex += block "Get-MMRole -Name 'system_user'" (fmtl $role)

# Get system_admin role
$adminRole = Get-MMRole -Name 'system_admin'
$ex += block "Get-MMRole -Name 'system_admin'" (fmtl $adminRole)

# Show permissions list
$ex += block "Get-MMRole -Name 'system_user' | Select-Object -ExpandProperty Permissions" `
    (($role.Permissions | Format-Table -AutoSize | Out-String).TrimEnd())

Update-WikiPage '05.-Roles.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
