# Generates example output for Get-MMUser wiki documentation
# Run from Sandbox/ after `make start`

param(
    [string]$OutputFile = (Join-Path $PSScriptRoot '../docs-examples/Get-MMUser.md'),
    [string]$Url           = 'http://localhost:8065',
    [string]$AdminUsername = 'admin',
    [string]$AdminPassword = 'Admin123456!',
    [string]$TestUsername  = 'testuser'
)

$modulePath = Join-Path $PSScriptRoot '../MatterMostV4/MatterMostV4.psd1'
Import-Module $modulePath -Force

Connect-MMServer -Url $Url -Username $AdminUsername -Password (ConvertTo-SecureString $AdminPassword -AsPlainText -Force)

function Format-PSOutput {
    param($Object)
    if ($null -eq $Object) { return '(no output)' }
    $Object | Format-List | Out-String | ForEach-Object { $_.TrimEnd() }
}

function Format-PSTableOutput {
    param($Object)
    if ($null -eq $Object) { return '(no output)' }
    $Object | Format-Table -AutoSize | Out-String | ForEach-Object { $_.TrimEnd() }
}

$sb = [System.Text.StringBuilder]::new()

$null = $sb.AppendLine('# Get-MMUser — Examples with Output')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('> Auto-generated against MatterMost sandbox. Do not edit manually.')
$null = $sb.AppendLine('')

# -Me (default)
$null = $sb.AppendLine('## Default — current authenticated user')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMUser')
$result = Get-MMUser
$null = $sb.AppendLine((Format-PSOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -Username
$null = $sb.AppendLine('## By username')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Username '$TestUsername'")
$result = Get-MMUser -Username $TestUsername
$null = $sb.AppendLine((Format-PSOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -UserId
$adminUser = Get-MMUser -Username $AdminUsername

# -Email
$null = $sb.AppendLine('## By email')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Email '$($adminUser.Email)'")
$result = Get-MMUser -Email $adminUser.Email
$null = $sb.AppendLine((Format-PSOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')
$null = $sb.AppendLine('## By ID')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -UserId '$($adminUser.Id)'")
$result = Get-MMUser -UserId $adminUser.Id
$null = $sb.AppendLine((Format-PSOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -Usernames (bulk)
$null = $sb.AppendLine('## Bulk by usernames')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Usernames '$AdminUsername', '$TestUsername'")
$testUser = Get-MMUser -Username $TestUsername
$result = Get-MMUser -Usernames $AdminUsername, $TestUsername
$null = $sb.AppendLine((Format-PSTableOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -Ids (bulk)
$null = $sb.AppendLine('## Bulk by IDs')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Ids '$($adminUser.Id)', '$($testUser.Id)'")
$result = Get-MMUser -Ids $adminUser.Id, $testUser.Id
$null = $sb.AppendLine((Format-PSTableOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -Filter
$null = $sb.AppendLine('## Filter by username (exact)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Filter {username -eq 'admin'}")
$result = Get-MMUser -Filter {username -eq 'admin'}
$null = $sb.AppendLine((Format-PSOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

$null = $sb.AppendLine('## Filter by username (wildcard)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUser -Filter {username -like 'test*'}")
$result = Get-MMUser -Filter {username -like 'test*'}
$null = $sb.AppendLine((Format-PSTableOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# -All
$null = $sb.AppendLine('## All users')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMUser -All')
$result = Get-MMUser -All
$null = $sb.AppendLine((Format-PSTableOutput $result))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine('')

# Pipeline
$null = $sb.AppendLine('## Pipeline — get team members then enrich with full user objects')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMTeam -Name 'testteam' | Get-MMTeamMembers | Get-MMUser")
$result = Get-MMTeam -Name 'testteam' | Get-MMTeamMembers | Get-MMUser
$null = $sb.AppendLine((Format-PSTableOutput $result))
$null = $sb.AppendLine('```')

# Write output
$outputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir | Out-Null }
$sb.ToString() | Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "Written to: $OutputFile"

Disconnect-MMServer
