# Generates examples with output for Channels wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

$team = Get-MMTeam -Name $MM_TEAM

# Get-MMChannel -All
$channels = Get-MMChannel -TeamId $team.Id
$ex += block "Get-MMChannel -TeamId `$team.Id" (fmtt $channels)

# Get-MMChannel -Name
$ch = Get-MMChannel -Name 'town-square' -TeamId $team.Id
$ex += block "Get-MMChannel -Name 'town-square'" (fmtl $ch)

# Get-MMChannel -Filter
$filtered = Get-MMChannel -TeamId $team.Id -Filter { $_.name -like 'town*' }
$ex += block "Get-MMChannel -Filter { `$_.name -like 'town*' }" (fmtt $filtered)

# New-MMChannel
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$newCh = New-MMChannel -TeamId $team.Id -Name "demo-channel-$rnd" -DisplayName "Demo Channel $rnd" -Type Public
$ex += block "New-MMChannel -TeamId `$team.Id -Name 'demo-channel' -DisplayName 'Demo Channel' -Type Public" (fmtl $newCh)

# Get-MMChannelMembers
$members = Get-MMChannelMembers -ChannelId $ch.Id
$ex += block "Get-MMChannelMembers -ChannelId `$ch.Id" (fmtt $members)

# Get-MMUserChannels
$me = Get-MMUser
$userChannels = Get-MMUserChannels -UserId $me.Id -TeamId $team.Id
$ex += block "Get-MMUser | Get-MMUserChannels -TeamId `$team.Id" (fmtt $userChannels)

# New-MMDirectChannel
$testUser = Get-MMUser -Username $MM_TESTUSER
$dm = New-MMDirectChannel -UserId1 $me.Id -UserId2 $testUser.Id
$ex += block "New-MMDirectChannel -UserId1 `$user1.Id -UserId2 `$user2.Id" (fmtl $dm)

# Cleanup
Remove-MMChannel -ChannelId $newCh.Id | Out-Null

Update-WikiPage '07.-Channels.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
