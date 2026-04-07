# Генератор реального вывода для wiki-страницы Reactions

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$me      = Get-MMUser
$channel = Get-MMChannel -Name 'town-square'
$post    = Send-MMMessage -ToChannel 'town-square' -Message 'Wiki reaction example post'

$sb = [System.Text.StringBuilder]::new()

# Add-MMPostReaction
$r1 = Add-MMPostReaction -PostId $post.id -EmojiName 'thumbsup'
$null = $sb.AppendLine('### Add a reaction to a post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Add-MMPostReaction -PostId '$($post.id)' -EmojiName 'thumbsup'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $r1))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Add via pipeline
$r2 = $post | Add-MMPostReaction -EmojiName 'heart'
$null = $sb.AppendLine('### Add a reaction via pipeline')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMPost -PostId '$($post.id)' | Add-MMPostReaction -EmojiName 'heart'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $r2))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMPostReactions
$reactions = Get-MMPostReactions -PostId $post.id
$null = $sb.AppendLine('### Get all reactions on a post')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMPostReactions -PostId '$($post.id)'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $reactions))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMBulkPostReactions
$post2 = Send-MMMessage -ToChannel 'town-square' -Message 'Wiki bulk reaction example post'
Add-MMPostReaction -PostId $post2.id -EmojiName 'rocket' | Out-Null

$bulk = Get-MMBulkPostReactions -PostIds $post.id, $post2.id
$null = $sb.AppendLine('### Get reactions for multiple posts at once')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMBulkPostReactions -PostIds '$($post.id)', '$($post2.id)'")
$null = $sb.AppendLine()
foreach ($key in $bulk.Keys) {
    $null = $sb.AppendLine("# $key")
    $null = $sb.AppendLine((fmtt $bulk[$key]))
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Remove-MMPostReaction
Remove-MMPostReaction -PostId $post.id -EmojiName 'thumbsup' | Out-Null
$removed = Remove-MMPostReaction -PostId $post.id -EmojiName 'heart'
$null = $sb.AppendLine('### Remove a reaction')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMPostReaction -PostId '$($post.id)' -EmojiName 'heart'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $removed))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Cleanup
Remove-MMPost -PostId $post.id  | Out-Null
Remove-MMPost -PostId $post2.id | Out-Null

Update-WikiPage -FileName '13.-Reactions.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
