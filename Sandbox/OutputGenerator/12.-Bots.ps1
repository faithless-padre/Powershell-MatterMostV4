# Generates examples with output for Bots wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

$rnd = Get-Random -Minimum 1000 -Maximum 9999

# New-MMBot
$bot = New-MMBot -Username "demo-bot-$rnd" -DisplayName 'Demo Bot' -Description 'Wiki example bot'
$ex += block "New-MMBot -Username 'ci-bot' -DisplayName 'CI Bot' -Description 'Continuous integration notifications'" (fmtl $bot)

# Get-MMBot
$bots = Get-MMBot
$ex += block 'Get-MMBot' (fmtt $bots)

# Get-MMBot -Filter
$filtered = Get-MMBot -Filter { $_.username -like 'demo*' }
$ex += block "Get-MMBot -Filter { `$_.username -like 'demo*' }" (fmtt $filtered)

# Set-MMBot
$updated = Set-MMBot -BotUserId $bot.UserId -DisplayName 'Demo Bot v2' -Description 'Updated description'
$ex += block "Get-MMBot -Filter { `$_.username -eq 'demo-bot' } | Set-MMBot -Description 'Updated description'" (fmtl $updated)

# Disable-MMBot
Disable-MMBot -BotUserId $bot.UserId | Out-Null
$ex += block "Get-MMBot -Filter { `$_.username -eq 'demo-bot' } | Disable-MMBot" 'status : OK'

# Get-MMBot -IncludeDeleted
$withDeleted = Get-MMBot -IncludeDeleted
$ex += block 'Get-MMBot -IncludeDeleted' (fmtt $withDeleted)

# Enable-MMBot
Enable-MMBot -BotUserId $bot.UserId | Out-Null
$ex += block "Get-MMBot -IncludeDeleted -Filter { `$_.username -eq 'demo-bot' } | Enable-MMBot" 'status : OK'

# Cleanup
Disable-MMBot -BotUserId $bot.UserId | Out-Null

Update-WikiPage '12.-Bots.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
