# Generates examples with output for Teams wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

# Get-MMTeam -All
$teams = Get-MMTeam -All
$ex += block 'Get-MMTeam -All' (fmtt $teams)

# Get-MMTeam -Name
$team = Get-MMTeam -Name $MM_TEAM
$ex += block "Get-MMTeam -Name '$MM_TEAM'" (fmtl $team)

# Get-MMTeam -Filter
$filtered = Get-MMTeam -Filter { $_.display_name -like 'Test*' }
$ex += block "Get-MMTeam -Filter { `$_.display_name -like 'Test*' }" (fmtt $filtered)

# Get-MMTeamMembers
$members = Get-MMTeamMembers -TeamId $team.Id
$ex += block "Get-MMTeamMembers -TeamId `$team.Id" (fmtt $members)

# Get-MMUserTeams
$me = Get-MMUser
$userTeams = Get-MMUserTeams -UserId $me.Id
$ex += block 'Get-MMUser | Get-MMUserTeams' (fmtt $userTeams)

# New-MMTeam
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$newTeam = New-MMTeam -Name "demo-team-$rnd" -DisplayName "Demo Team $rnd" -Type Open
$ex += block "New-MMTeam -Name 'demo-team' -DisplayName 'Demo Team' -Type Open" (fmtl $newTeam)

# Add-MMUserToTeam
$testUser = Get-MMUser -Username $MM_TESTUSER
Add-MMUserToTeam -TeamId $newTeam.Id -UserId $testUser.Id | Out-Null
$ex += block "Get-MMUser -Username 'jdoe' | Add-MMUserToTeam -TeamId `$team.Id" "status : OK"

# Remove-MMTeam (archive)
Remove-MMTeam -TeamId $newTeam.Id | Out-Null
$ex += block "Get-MMTeam -Name 'demo-team' | Remove-MMTeam" "status : OK"

Update-WikiPage '08.-Teams.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
