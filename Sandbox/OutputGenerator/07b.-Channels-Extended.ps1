# Генератор реального вывода для расширенных Channels cmdlets (wiki 07)

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$channel = Get-MMChannel -Name 'town-square'
$team    = Get-MMTeam
$me      = Get-MMUser

$sb = [System.Text.StringBuilder]::new()

# Search-MMChannel
$found = Search-MMChannel -Term 'town'
$null = $sb.AppendLine('### Search for channels by name')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Search-MMChannel -Term 'town'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($found | Select-Object -First 3)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMChannelStats
$stats = Get-MMChannelStats -ChannelId $channel.id
$null = $sb.AppendLine('### Get channel statistics')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMChannelStats -ChannelId '$($channel.id)'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $stats))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMChannelPinnedPosts
$pinned = Get-MMChannelPinnedPosts -ChannelId $channel.id
$null = $sb.AppendLine('### Get pinned posts in a channel')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMChannelPinnedPosts -ChannelId '$($channel.id)'")
$null = $sb.AppendLine()
if ($pinned) {
    $null = $sb.AppendLine((fmtt ($pinned | Select-Object -First 2)))
} else {
    $null = $sb.AppendLine('(no pinned posts)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMChannelViewed
Set-MMChannelViewed -ChannelId $channel.id
$null = $sb.AppendLine('### Mark channel as viewed (clear unread)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMChannelViewed -ChannelId '$($channel.id)'")
$null = $sb.AppendLine('# (no output — marks channel read for current user)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMChannelMemberRoles
Set-MMChannelMemberRoles -ChannelId $channel.id -UserId $me.id -Roles 'channel_user'
$null = $sb.AppendLine('### Update channel member roles')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMChannelMemberRoles -ChannelId '$($channel.id)' -UserId '$($me.id)' -Roles 'channel_user'")
$null = $sb.AppendLine('# (no output — roles updated)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMChannelMemberNotifyProps
Set-MMChannelMemberNotifyProps -ChannelId $channel.id -UserId $me.id -Desktop 'mention'
$null = $sb.AppendLine('### Update channel notification preferences')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMChannelMemberNotifyProps -ChannelId '$($channel.id)' -UserId '$($me.id)' -Desktop 'mention'")
$null = $sb.AppendLine('# (no output — notify props updated)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Sidebar Categories
$cats = Get-MMSidebarCategories
$null = $sb.AppendLine('### Get sidebar categories')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMSidebarCategories')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $cats))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$newCat = New-MMSidebarCategory -DisplayName 'Wiki Example Category'
$null = $sb.AppendLine('### Create a custom sidebar category')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMSidebarCategory -DisplayName 'Wiki Example Category'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $newCat))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Cleanup
Remove-MMSidebarCategory -CategoryId $newCat.id -Confirm:$false

$order = Get-MMSidebarCategoryOrder
$null = $sb.AppendLine('### Get sidebar category order')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMSidebarCategoryOrder')
$null = $sb.AppendLine()
$null = $sb.AppendLine(($order -join "`n"))
$null = $sb.AppendLine('```')

# Append to existing channels wiki page
$path = Join-Path $script:WikiPath '07.-Channels.md'
$content = Get-Content $path -Raw
$marker = '## Examples'
$idx = $content.IndexOf($marker)
if ($idx -ge 0) {
    $before = $content.Substring(0, $idx)
    $newContent = $before + $marker + "`n`n" + "## Extended Cmdlets`n`n" + $sb.ToString().TrimStart()
    $newContent | Set-Content -Path $path -Encoding UTF8 -NoNewline
    Write-Host "Updated: 07.-Channels.md"
} else {
    $appendContent = "`n`n## Extended Cmdlets`n`n" + $sb.ToString()
    Add-Content -Path $path -Value $appendContent -Encoding UTF8
    Write-Host "Appended to: 07.-Channels.md"
}
Write-Host 'Done.'
