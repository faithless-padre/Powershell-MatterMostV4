# Generates examples with output for Status wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

$me = Get-MMUser

# Get status
$status = Get-MMUserStatus -UserId $me.Id
$ex += block "Get-MMUser | Get-MMUserStatus" (fmtl $status)

# Set online
$result = Set-MMUserStatus -UserId $me.Id -Status online
$ex += block "Get-MMUser | Set-MMUserStatus -Status online" (fmtl $result)

# Set dnd
$result = Set-MMUserStatus -UserId $me.Id -Status dnd
$ex += block "Get-MMUser | Set-MMUserStatus -Status dnd" (fmtl $result)

# Set custom status
Set-MMUserCustomStatus -UserId $me.Id -Emoji 'house' -Text 'Working from home'
$status2 = Get-MMUserStatus -UserId $me.Id
$ex += block "Set-MMUserCustomStatus -UserId `$me.Id -Emoji 'house' -Text 'Working from home'" (fmtl $status2)

# Remove custom status
Remove-MMUserCustomStatus -UserId $me.Id
$ex += block "Get-MMUser | Remove-MMUserCustomStatus" "status : OK"

# Restore online
Set-MMUserStatus -UserId $me.Id -Status online | Out-Null

Update-WikiPage '06.-Status.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
