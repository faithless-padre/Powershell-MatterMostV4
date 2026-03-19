# Generates examples with output for Emoji wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

# Create a test emoji first (1x1 transparent PNG)
$pngBytes = [Convert]::FromBase64String(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
)
$tmpPng = [System.IO.Path]::GetTempFileName() + '.png'
[System.IO.File]::WriteAllBytes($tmpPng, $pngBytes)

$me = Get-MMUser
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$emojiName = "test-blob-$rnd"

# New-MMEmoji
$newEmoji = New-MMEmoji -Name $emojiName -ImagePath $tmpPng -CreatorId $me.Id
$ex += block "New-MMEmoji -Name 'test-blob' -ImagePath './blob.png' -CreatorId `$me.Id" (fmtl $newEmoji)

# Get-MMEmoji -All
$all = Get-MMEmoji
$ex += block 'Get-MMEmoji' (fmtt $all)

# Get-MMEmoji -Name
$emoji = Get-MMEmoji -Name $emojiName
$ex += block "Get-MMEmoji -Name '$emojiName'" (fmtl $emoji)

# Find-MMEmoji
$found = Find-MMEmoji -Term 'blob'
$ex += block "Find-MMEmoji -Term 'blob'" (fmtt $found)

# Save-MMEmojiImage
$tmpDir = Join-Path ([System.IO.Path]::GetTempPath()) "emoji-dl-$rnd"
New-Item -ItemType Directory -Path $tmpDir | Out-Null
Save-MMEmojiImage -EmojiId $emoji.Id -EmojiName $emoji.Name -DestinationPath $tmpDir | Out-Null
$ex += block "Get-MMEmoji | Save-MMEmojiImage -DestinationPath './emoji-backup'" "Saved $emojiName.png -> $tmpDir"

# Remove-MMEmoji
Remove-MMEmoji -EmojiId $emoji.Id | Out-Null
$ex += block "Get-MMEmoji -Name '$emojiName' | Remove-MMEmoji" 'status : OK'

# Cleanup
Remove-Item $tmpPng -ErrorAction SilentlyContinue
Remove-Item $tmpDir -Recurse -ErrorAction SilentlyContinue

Update-WikiPage '09.-Emoji.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
