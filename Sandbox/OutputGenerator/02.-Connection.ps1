# Generates examples with output for Connection wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

# Connect-MMServer
$sec = ConvertTo-SecureString $MM_PASS -AsPlainText -Force
$session = Connect-MMServer -Url $MM_URL -Username $MM_USER -Password $sec
$ex += block "Connect-MMServer -Url '$MM_URL' -Credential (Get-Credential)" (fmtl $session)

# With token
$ex += @"
``````powershell
# Personal Access Token
PS> Connect-MMServer -Url '$MM_URL' -Token 'your-personal-access-token'

Url           : $MM_URL
Username      : admin
UserId        : $($session.UserId)
AuthType      : Token
DefaultTeamId :
``````
"@

# Disconnect
$ex += @"
``````powershell
PS> Disconnect-MMServer

status : OK
``````
"@

Update-WikiPage '02.-Connection.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
