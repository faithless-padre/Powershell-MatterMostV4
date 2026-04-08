# Генератор реального вывода для wiki-страницы Teams (расширенные командлеты)

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Get-MMTeamStats
$team  = Get-MMTeam -Name $MM_TEAM
$stats = Get-MMTeamStats -TeamId $team.Id
$null = $sb.AppendLine('### Get team statistics')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMTeamStats -TeamId (Get-MMTeam -Name testteam).Id')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $stats))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMTeamUnreads
$unreads = Get-MMTeamUnreads | Select-Object team_id, msg_count, mention_count | Select-Object -First 5
$null = $sb.AppendLine('### Get unread counts for all teams (current user)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMTeamUnreads | Select-Object team_id, msg_count, mention_count | Select-Object -First 5')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $unreads))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMTeamInviteInfo
$inviteId = $team.InviteId
$info     = Get-MMTeamInviteInfo -InviteId $inviteId
$null = $sb.AppendLine('### Get public team info via invite link')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> $team = Get-MMTeam -Name testteam')
$null = $sb.AppendLine("PS> Get-MMTeamInviteInfo -InviteId `$team.InviteId")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $info))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Reset-MMTeamInvite
$updated = Reset-MMTeamInvite -TeamId $team.Id -Confirm:$false
$null = $sb.AppendLine('### Regenerate team invite ID')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Reset-MMTeamInvite -TeamId `$team.Id")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $updated))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMTeamIcon
$null = $sb.AppendLine('### Download the team icon')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMTeamIcon -TeamId `$team.Id -OutFile '/tmp/team-icon.png'")
$null = $sb.AppendLine()
try {
    $iconFile = Get-MMTeamIcon -TeamId $team.Id -OutFile '/tmp/team-icon.png'
    $null = $sb.AppendLine((fmtl $iconFile))
}
catch {
    $null = $sb.AppendLine("# (no icon set on this team: $($_.Exception.Message.Split(':')[0]))")
}
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '08.-Teams.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
