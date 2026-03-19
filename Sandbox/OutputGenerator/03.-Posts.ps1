# Generates examples with output for Posts wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')

# Posts need DefaultTeam for Send-MMMessage -ToChannel
Import-Module $script:ModulePath -Force
$sec = ConvertTo-SecureString $MM_PASS -AsPlainText -Force
Connect-MMServer -Url $MM_URL -Username $MM_USER -Password $sec -DefaultTeam $MM_TEAM | Out-Null

$ex = @()

$team    = Get-MMTeam -Name $MM_TEAM
$channel = Get-MMChannel -Name 'town-square' -TeamId $team.Id

# Send-MMMessage
$post1 = Send-MMMessage -ToChannel 'town-square' -Message 'Hello from MatterMostV4!'
$ex += block "Send-MMMessage -ToChannel 'town-square' -Message 'Hello from MatterMostV4!'" (fmtl $post1)

# New-MMPost (reply in thread)
$reply = New-MMPost -ChannelId $channel.Id -Message 'This is a thread reply' -RootId $post1.Id
$ex += block "New-MMPost -ChannelId `$channel.Id -Message 'This is a thread reply' -RootId `$post.Id" (fmtl $reply)

# Get-MMPost
$fetched = Get-MMPost -PostId $post1.Id
$ex += block "Get-MMPost -PostId '$($post1.Id)'" (fmtl $fetched)

# Get-MMPostThread
$thread = Get-MMPostThread -PostId $post1.Id
$ex += block "Get-MMPostThread -PostId `$post.Id" (fmtt $thread)

# Get-MMChannelPosts
$posts = Get-MMChannelPosts -ChannelId $channel.Id -PerPage 5
$ex += block "Get-MMChannelPosts -ChannelName 'town-square' -PerPage 5" (fmtt $posts)

# Get-MMMessage
$msg = Get-MMMessage -PostId $post1.Id
$ex += block "Get-MMMessage -PostId `$post.Id" (fmtl $msg)

# Set-MMPost
$edited = Set-MMPost -PostId $post1.Id -Message 'Hello from MatterMostV4! (edited)'
$ex += block "Set-MMPost -PostId `$post.Id -Message 'Corrected message'" (fmtl $edited)

# Add-MMPostPin
Add-MMPostPin -PostId $post1.Id | Out-Null
$ex += block "Add-MMPostPin -PostId `$post.Id" 'status : OK'

# Remove-MMPostPin
Remove-MMPostPin -PostId $post1.Id | Out-Null
$ex += block "Remove-MMPostPin -PostId `$post.Id" 'status : OK'

# Remove-MMPost
Remove-MMPost -PostId $reply.Id | Out-Null
Remove-MMPost -PostId $post1.Id | Out-Null
$ex += block "Remove-MMPost -PostId `$post.Id" 'status : OK'

Update-WikiPage '03.-Posts.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
