# Генератор реального вывода для wiki-страницы Commands (Slash Commands) API

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Resolve team ID for testteam
$team = Get-MMTeam -Name $MM_TEAM
$teamId = $team.id

# New-MMCommand
$cmd = New-MMCommand -TeamId $teamId -Trigger 'wikidemo' -URL 'https://example.com/wikidemo' `
    -DisplayName 'Wiki Demo' -Description 'Demo command for wiki' -AutoComplete
$null = $sb.AppendLine('### Create a new slash command')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMCommand -TeamId '<teamId>' -Trigger 'wikidemo' -URL 'https://example.com/wikidemo' -DisplayName 'Wiki Demo' -AutoComplete")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $cmd))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMCommand by TeamId
$cmds = Get-MMCommand -TeamId $teamId
$null = $sb.AppendLine('### List slash commands for a team')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMCommand -TeamId '<teamId>'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($cmds | Select-Object id, trigger, display_name, url)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMCommand by CommandId
$cmdById = Get-MMCommand -CommandId $cmd.id
$null = $sb.AppendLine('### Get a specific slash command by ID')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMCommand -CommandId '<commandId>'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $cmdById))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMCommand
$updated = Set-MMCommand -CommandId $cmd.id -DisplayName 'Wiki Demo Updated' -Description 'Updated description'
$null = $sb.AppendLine('### Update an existing slash command')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMCommand -CommandId '<commandId>' -DisplayName 'Wiki Demo Updated' -Description 'Updated description'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl ($updated | Select-Object id, trigger, display_name, description)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Reset-MMCommandToken
$tokenResult = Reset-MMCommandToken -CommandId $cmd.id -Confirm:$false
$null = $sb.AppendLine('### Regenerate slash command security token')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Reset-MMCommandToken -CommandId '<commandId>'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $tokenResult))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Move-MMCommand — create a second team, move command there
$team2Name = 'wikimoveteam'
$existingTeam2 = try { Get-MMTeam -Name $team2Name } catch { $null }
if ($null -eq $existingTeam2) {
    $team2 = New-MMTeam -Name $team2Name -DisplayName 'Wiki Move Test Team'
} else {
    $team2 = $existingTeam2
}
Move-MMCommand -CommandId $cmd.id -TeamId $team2.id -Confirm:$false
$null = $sb.AppendLine('### Move a slash command to another team')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Move-MMCommand -CommandId '<commandId>' -TeamId '<targetTeamId>'")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Remove-MMCommand
Remove-MMCommand -CommandId $cmd.id -Confirm:$false
$null = $sb.AppendLine('### Delete a slash command')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMCommand -CommandId '<commandId>'")
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '17.-Commands.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
