# Генератор реального вывода для wiki-страницы OAuth Apps

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

# Включаем OAuth service provider если выключен
$cfg = Get-MMServerConfig
if (-not $cfg.ServiceSettings.EnableOAuthServiceProvider) {
    Write-Host 'Enabling EnableOAuthServiceProvider...'
    Set-MMServerConfig -ServiceSettings @{ EnableOAuthServiceProvider = $true } | Out-Null
}

# Выдаём manage_oauth permission на role system_user (нужно для создания OAuth apps через API)
$session = & (Get-Module MatterMostV4) { $script:MMSession }
$roleResp = Invoke-WebRequest -Uri "$($session.Url)/api/v4/roles/name/system_user" -Method GET -Headers @{Authorization="Bearer $($session.Token)"}
$role = $roleResp.Content | ConvertFrom-Json
if ('manage_oauth' -notin $role.permissions) {
    Write-Host 'Granting manage_oauth to system_user role...'
    $newPerms = $role.permissions + 'manage_oauth'
    $patchBody = @{ permissions = $newPerms } | ConvertTo-Json -Compress
    Invoke-WebRequest -Uri "$($session.Url)/api/v4/roles/$($role.id)/patch" -Method PUT -Headers @{Authorization="Bearer $($session.Token)"; 'Content-Type'='application/json'} -Body $patchBody | Out-Null
}

$sb = [System.Text.StringBuilder]::new()

# New-MMOAuthApp
$app = New-MMOAuthApp `
    -Name 'WikiDemoApp' `
    -Description 'Demo OAuth app for wiki examples' `
    -CallbackUrls 'https://example.com/callback' `
    -Homepage 'https://example.com'

$null = $sb.AppendLine('### Register a new OAuth application')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> New-MMOAuthApp -Name 'WikiDemoApp' -Description 'Demo OAuth app for wiki examples' -CallbackUrls 'https://example.com/callback' -Homepage 'https://example.com'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $app))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMOAuthApp (list)
$apps = Get-MMOAuthApp
$null = $sb.AppendLine('### List all OAuth applications')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMOAuthApp')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($apps | Select-Object id, name, description, homepage)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMOAuthApp by ID
$single = Get-MMOAuthApp -AppId $app.id
$null = $sb.AppendLine('### Get a specific OAuth application by ID')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMOAuthApp -AppId '$($app.id)'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $single))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMOAuthApp
$updated = Set-MMOAuthApp -AppId $app.id -Description 'Updated description for wiki demo'
$null = $sb.AppendLine('### Update an OAuth application')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMOAuthApp -AppId '$($app.id)' -Description 'Updated description for wiki demo'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl ($updated | Select-Object id, name, description)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Reset-MMOAuthAppSecret
$reset = Reset-MMOAuthAppSecret -AppId $app.id
$null = $sb.AppendLine('### Regenerate client secret')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Reset-MMOAuthAppSecret -AppId '$($app.id)'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl ($reset | Select-Object id, name, client_secret)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Remove-MMOAuthApp
Remove-MMOAuthApp -AppId $app.id
$null = $sb.AppendLine('### Delete an OAuth application')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMOAuthApp -AppId '$($app.id)'")
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '20.-OAuth-Apps.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
