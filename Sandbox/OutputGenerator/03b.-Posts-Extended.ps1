# Генератор реального вывода для расширенных Posts cmdlets (wiki 03)

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$channel = Get-MMChannel -Name 'town-square'
$team    = Get-MMTeam
$me      = Get-MMUser

$sb = [System.Text.StringBuilder]::new()

# Search-MMPost
$post = New-MMPost -ChannelId $channel.id -Message 'WikiSearchExample_MatterMostV4'
Start-Sleep -Milliseconds 500
$results = Search-MMPost -Terms 'WikiSearchExample_MatterMostV4'
$null = $sb.AppendLine('### Search for posts by text')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Search-MMPost -Terms 'WikiSearchExample_MatterMostV4'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($results | Select-Object -First 1 | Select-Object id, message, channel_id)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()
Remove-MMPost -PostId $post.id

# Get-MMFlaggedPosts
$null = $sb.AppendLine('### Get flagged (bookmarked) posts')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMFlaggedPosts')
$null = $sb.AppendLine()
$flagged = Get-MMFlaggedPosts
if ($flagged) {
    $null = $sb.AppendLine((fmtt ($flagged | Select-Object -First 3)))
} else {
    $null = $sb.AppendLine('# (no flagged posts for this user)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMPostFileInfo
$testPost = New-MMPost -ChannelId $channel.id -Message 'WikiFileInfoTest'
$fileInfo = Get-MMPostFileInfo -PostId $testPost.id
$null = $sb.AppendLine('### Get file metadata for a post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMPostFileInfo -PostId '$($testPost.id)'")
$null = $sb.AppendLine()
if ($fileInfo) {
    $null = $sb.AppendLine((fmtt $fileInfo))
} else {
    $null = $sb.AppendLine('# (empty — post has no attachments)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()
Remove-MMPost -PostId $testPost.id

# Set-MMPostUnread
$unreadPost = New-MMPost -ChannelId $channel.id -Message 'WikiUnreadTest'
Set-MMPostUnread -PostId $unreadPost.id
$null = $sb.AppendLine('### Mark post as unread')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMPostUnread -PostId '$($unreadPost.id)'")
$null = $sb.AppendLine('# (no output — post marked as unread for current user)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()
Remove-MMPost -PostId $unreadPost.id

# New-MMEphemeralPost
$eph = New-MMEphemeralPost -UserId $me.id -ChannelId $channel.id -Message 'Wiki ephemeral example'
$null = $sb.AppendLine('### Create an ephemeral post (visible only to one user)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMEphemeralPost -UserId '$($me.id)' -ChannelId '$($channel.id)' -Message 'You have a notification'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl ($eph | Select-Object id, message, channel_id, type)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# New-MMPostReminder
$remPost = New-MMPost -ChannelId $channel.id -Message 'WikiReminderTest'
New-MMPostReminder -PostId $remPost.id -RemindAt (Get-Date).AddHours(2)
$null = $sb.AppendLine('### Set a reminder for a post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMPostReminder -PostId '$($remPost.id)' -RemindAt (Get-Date).AddHours(2)")
$null = $sb.AppendLine('# (no output — reminder created)')
$null = $sb.AppendLine('```')
Remove-MMPost -PostId $remPost.id

# Append to posts wiki page
$path = Join-Path $script:WikiPath '03.-Posts.md'
$content = Get-Content $path -Raw
$marker = '## Examples'
$idx = $content.IndexOf($marker)
if ($idx -ge 0) {
    $before = $content.Substring(0, $idx)
    $newContent = $before + $marker + "`n`n## Extended Cmdlets`n`n" + $sb.ToString().TrimStart()
    $newContent | Set-Content -Path $path -Encoding UTF8 -NoNewline
    Write-Host "Updated: 03.-Posts.md"
} else {
    Add-Content -Path $path -Value ("`n`n## Extended Cmdlets`n`n" + $sb.ToString()) -Encoding UTF8
    Write-Host "Appended to: 03.-Posts.md"
}
Write-Host 'Done.'
