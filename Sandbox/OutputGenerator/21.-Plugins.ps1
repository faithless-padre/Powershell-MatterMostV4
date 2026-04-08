# Генератор реального вывода для wiki-страницы Plugins

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Get-MMPlugin
$plugins = Get-MMPlugin
$null = $sb.AppendLine('### List installed plugins')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMPlugin')
$null = $sb.AppendLine()
$null = $sb.AppendLine('# Active plugins:')
if ($plugins.active -and $plugins.active.Count -gt 0) {
    $null = $sb.AppendLine((fmtt ($plugins.active | Select-Object id, name, version, description)))
} else {
    $null = $sb.AppendLine('(none)')
}
$null = $sb.AppendLine()
$null = $sb.AppendLine('# Inactive plugins:')
if ($plugins.inactive -and $plugins.inactive.Count -gt 0) {
    $null = $sb.AppendLine((fmtt ($plugins.inactive | Select-Object id, name, version, description)))
} else {
    $null = $sb.AppendLine('(none)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMPluginStatus
$statuses = Get-MMPluginStatus
$null = $sb.AppendLine('### Get plugin runtime status')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMPluginStatus')
$null = $sb.AppendLine()
$null = $sb.AppendLine('# State values: 0 = not running, 1 = starting, 2 = running, 3 = failing')
if ($statuses -and @($statuses).Count -gt 0) {
    $null = $sb.AppendLine((fmtt ($statuses | Select-Object plugin_id, name, version, state)))
} else {
    $null = $sb.AppendLine('(no plugins installed)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Enable/Disable: try with an inactive plugin
$inactivePlugin = if ($plugins.inactive -and $plugins.inactive.Count -gt 0) { $plugins.inactive[0] } else { $null }
$activePlugin   = if ($plugins.active   -and $plugins.active.Count   -gt 0) { $plugins.active[0]   } else { $null }

if ($inactivePlugin) {
    Enable-MMPlugin -PluginId $inactivePlugin.id
    $null = $sb.AppendLine('### Enable an inactive plugin')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Enable-MMPlugin -PluginId '$($inactivePlugin.id)'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()

    Disable-MMPlugin -PluginId $inactivePlugin.id
    $null = $sb.AppendLine('### Disable an active plugin')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Disable-MMPlugin -PluginId '$($inactivePlugin.id)'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()
} elseif ($activePlugin) {
    Disable-MMPlugin -PluginId $activePlugin.id
    $null = $sb.AppendLine('### Disable an active plugin')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Disable-MMPlugin -PluginId '$($activePlugin.id)'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()

    Enable-MMPlugin -PluginId $activePlugin.id
    $null = $sb.AppendLine('### Re-enable a plugin')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Enable-MMPlugin -PluginId '$($activePlugin.id)'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()
} else {
    $null = $sb.AppendLine('### Enable / Disable a plugin')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Enable-MMPlugin -PluginId 'com.example.myplugin'")
    $null = $sb.AppendLine("PS> Disable-MMPlugin -PluginId 'com.example.myplugin'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()
}

# Install-MMPlugin / Remove-MMPlugin — показываем синтаксис, без реального файла
$null = $sb.AppendLine('### Install a plugin from URL')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Install-MMPlugin -PluginDownloadUrl 'https://example.com/plugin.tar.gz'")
$null = $sb.AppendLine('# -Force overwrites an existing plugin with the same ID')
$null = $sb.AppendLine("PS> Install-MMPlugin -PluginDownloadUrl 'https://example.com/plugin.tar.gz' -Force")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$null = $sb.AppendLine('### Install a plugin from a local file')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Install-MMPlugin -FilePath '/tmp/myplugin.tar.gz'")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

$null = $sb.AppendLine('### Remove an installed plugin')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMPlugin -PluginId 'com.example.myplugin'")
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '21.-Plugins.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
