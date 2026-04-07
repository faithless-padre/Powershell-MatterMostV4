# Генератор реального вывода для wiki-страницы System API

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Test-MMServer
$ping = Test-MMServer
$null = $sb.AppendLine('### Check server health')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Test-MMServer')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $ping))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMServerTimezones
$tz = Get-MMServerTimezones | Select-Object -First 5
$null = $sb.AppendLine('### Get supported timezones (first 5)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMServerTimezones | Select-Object -First 5')
$null = $sb.AppendLine()
$null = $sb.AppendLine(($tz -join "`n"))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMLicenseInfo
$lic = Get-MMLicenseInfo
$null = $sb.AppendLine('### Get license information')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMLicenseInfo')
$null = $sb.AppendLine()
$licFields = $lic.PSObject.Properties | Select-Object -First 6
foreach ($f in $licFields) {
    $null = $sb.AppendLine("$($f.Name.PadRight(20)): $($f.Value)")
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMServerLogs
$logs = Get-MMServerLogs -PerPage 3
$null = $sb.AppendLine('### Get server logs (last 3 entries)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMServerLogs -PerPage 3')
$null = $sb.AppendLine()
$null = $sb.AppendLine(($logs | Select-Object -Last 3 | Out-String).TrimEnd())
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMServerAudits
$audits = Get-MMServerAudits -PerPage 3
$null = $sb.AppendLine('### Get audit log (last 3 entries)')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMServerAudits -PerPage 3')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $audits))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Add-MMServerLogEntry
Add-MMServerLogEntry -Level 'info' -Message 'MatterMostV4 wiki example'
$null = $sb.AppendLine('### Write to server log')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Add-MMServerLogEntry -Level 'info' -Message 'MatterMostV4 wiki example'")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Clear-MMServerCaches
Clear-MMServerCaches -Confirm:$false
$null = $sb.AppendLine('### Invalidate server caches')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Clear-MMServerCaches')
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Invoke-MMDatabaseRecycle
Invoke-MMDatabaseRecycle -Confirm:$false
$null = $sb.AppendLine('### Recycle database connections')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Invoke-MMDatabaseRecycle')
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '15.-System.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
