# Генератор реального вывода для wiki-страницы Scheduled Posts
# ВНИМАНИЕ: Scheduled Posts требуют Enterprise/Professional лицензию.
# Этот скрипт создаёт страницу без примеров вывода при работе с Team Edition.

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$channel = Get-MMChannel -Name 'town-square'
$team    = Get-MMTeam
$future  = (Get-Date).AddDays(1)

$licensed = $true
try {
    $sp = New-MMScheduledPost -ChannelId $channel.id -Message 'wiki test' -ScheduledAt $future
} catch {
    if ($_ -match 'requires a license') {
        $licensed = $false
        Write-Warning 'Scheduled Posts require a license — skipping example output'
    } else {
        throw
    }
} finally {
    if ($licensed) {
        Get-MMScheduledPost -TeamId $team.id -ErrorAction SilentlyContinue | Remove-MMScheduledPost -ErrorAction SilentlyContinue
    }
}

$sb = [System.Text.StringBuilder]::new()

if (-not $licensed) {
    $null = $sb.AppendLine('> **Note:** Scheduled Posts require a MatterMost Enterprise or Professional license.')
    $null = $sb.AppendLine('> Examples below show the expected output format but were not captured from a live server.')
    $null = $sb.AppendLine()
}

$null = $sb.AppendLine('### Create a scheduled post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMScheduledPost -ChannelId 'ch123abc' -Message 'Hello, future!' -ScheduledAt (Get-Date '09:00')")
if ($licensed) {
    $sp2 = New-MMScheduledPost -ChannelId $channel.id -Message 'Hello, future!' -ScheduledAt $future
    $null = $sb.AppendLine()
    $null = $sb.AppendLine((fmtl $sp2))
    Get-MMScheduledPost -TeamId $team.id | Remove-MMScheduledPost -ErrorAction SilentlyContinue
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$null = $sb.AppendLine('### List scheduled posts for a team')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMScheduledPost')
$null = $sb.AppendLine()
$null = $sb.AppendLine('# or with explicit team:')
$null = $sb.AppendLine("PS> Get-MMTeam -Name 'dev' | Get-MMScheduledPost")
if ($licensed) {
    $list = Get-MMScheduledPost -TeamId $team.id
    $null = $sb.AppendLine()
    $null = $sb.AppendLine((fmtt $list))
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$null = $sb.AppendLine('### Update a scheduled post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMScheduledPost | Where-Object message -like '*Hello*' | Set-MMScheduledPost -Message 'Updated message'")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$null = $sb.AppendLine('### Delete a scheduled post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMScheduledPost -ScheduledPostId 'wix3qp5f7jy4zbnm8r6d1koeac'")
$null = $sb.AppendLine()
$null = $sb.AppendLine('# or via pipeline:')
$null = $sb.AppendLine('PS> Get-MMScheduledPost | Remove-MMScheduledPost')
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '14.-Scheduled-Posts.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
