# Генератор реального вывода для расширенных Users cmdlets (wiki 04)

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$me = Get-MMUser
$suffix = [System.DateTime]::Now.ToString('HHmmss')

$sb = [System.Text.StringBuilder]::new()

# Search-MMUser
$found = Search-MMUser -Term 'admin' -Limit 3
$null = $sb.AppendLine('### Search for users by name')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Search-MMUser -Term 'admin' -Limit 3")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $found))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Send-MMPasswordResetEmail
$testUser = New-MMUser -Username "wikiusr_$suffix" -Email "wikiusr_$suffix@test.local" `
    -Password (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) -FirstName 'Wiki' -LastName 'User'

Send-MMPasswordResetEmail -Email $testUser.email
$null = $sb.AppendLine('### Send password reset email')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Send-MMPasswordResetEmail -Email 'user@example.com'")
$null = $sb.AppendLine('# (no output — email queued)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMUserProfileImage (download)
$tmpImg = Join-Path ([System.IO.Path]::GetTempPath()) "wiki_avatar_$suffix.png"
Get-MMUserProfileImage -UserId $me.id -OutputPath $tmpImg
$null = $sb.AppendLine('### Download user profile image')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUserProfileImage -UserId '$($me.id)' -OutputPath './admin-avatar.png'")
$null = $sb.AppendLine('# (image saved to file — no pipeline output)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Remove-MMUserProfileImage
Remove-MMUserProfileImage -UserId $me.id
$null = $sb.AppendLine('### Reset user profile image to default')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMUserProfileImage -UserId '$($me.id)'")
$null = $sb.AppendLine('# (no output — reset to generated avatar)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMUserMFA (deactivate — no-op if not enabled)
Set-MMUserMFA -UserId $me.id
$null = $sb.AppendLine('### Disable MFA for user')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMUserMFA -UserId '$($me.id)'")
$null = $sb.AppendLine('# (no output — MFA deactivated; use -Activate with -Code to enable)')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMUsersByGroupChannel
$suffix2 = [System.DateTime]::Now.ToString('HHmmssf')
$user2 = New-MMUser -Username "wikigrp_$suffix2" -Email "wikigrp_$suffix2@test.local" `
    -Password (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) -FirstName 'Grp' -LastName 'Two'
$user3 = New-MMUser -Username "wikigrp3_$suffix2" -Email "wikigrp3_$suffix2@test.local" `
    -Password (ConvertTo-SecureString 'Test123456!' -AsPlainText -Force) -FirstName 'Grp' -LastName 'Three'
$gm = New-MMGroupChannel -UserIds @($me.id, $user2.id, $user3.id)
$bulk = Get-MMUsersByGroupChannel -GroupChannelIds $gm.id

$null = $sb.AppendLine('### Get users for group message channels')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMUsersByGroupChannel -GroupChannelIds '$($gm.id)'")
$null = $sb.AppendLine()
$null = $sb.AppendLine("# Returns a hashtable: key = channel_id, value = MMUser[]")
$null = $sb.AppendLine("\$result = Get-MMUsersByGroupChannel -GroupChannelIds '$($gm.id)'")
$null = $sb.AppendLine("\$result['$($gm.id)'] | Select-Object username, id")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($bulk[$gm.id] | Select-Object username, id)))
$null = $sb.AppendLine('```')

# Cleanup
if (Test-Path $tmpImg) { Remove-Item $tmpImg -Force }
Remove-MMUser -UserId $testUser.id
Remove-MMUser -UserId $user2.id
Remove-MMUser -UserId $user3.id

# Append to users wiki page
$path = Join-Path $script:WikiPath '04.-Users.md'
$content = Get-Content $path -Raw
$marker = '## Examples'
$idx = $content.IndexOf($marker)
if ($idx -ge 0) {
    $before = $content.Substring(0, $idx)
    $newContent = $before + $marker + "`n`n## Extended Cmdlets`n`n" + $sb.ToString().TrimStart()
    $newContent | Set-Content -Path $path -Encoding UTF8 -NoNewline
    Write-Host "Updated: 04.-Users.md"
} else {
    Add-Content -Path $path -Value ("`n`n## Extended Cmdlets`n`n" + $sb.ToString()) -Encoding UTF8
    Write-Host "Appended to: 04.-Users.md"
}
Write-Host 'Done.'
