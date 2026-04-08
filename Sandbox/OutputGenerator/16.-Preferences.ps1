# Генератор реального вывода для wiki-страницы Preferences API

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Get-MMPreferences
$prefs = Get-MMPreferences
$null = $sb.AppendLine('### Get all preferences for current user')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMPreferences | Select-Object -First 5')
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt ($prefs | Select-Object -First 5)))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Set-MMPreferences — set a test preference
$meId = (Get-MMUser -UserId 'me').id
$testPref = @{ user_id = $meId; category = 'display_settings'; name = 'wiki_test_pref'; value = 'test_value' }
Set-MMPreferences -Preferences @($testPref)
$null = $sb.AppendLine('### Save/update a user preference')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Set-MMPreferences -Preferences @(@{ user_id = '<me>'; category = 'display_settings'; name = 'wiki_test_pref'; value = 'test_value' })")
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMPreferencesByCategory
$catPrefs = Get-MMPreferencesByCategory -Category 'display_settings'
$null = $sb.AppendLine("### Get preferences by category 'display_settings'")
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMPreferencesByCategory -Category 'display_settings'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtt $catPrefs))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMPreference
$singlePref = Get-MMPreference -Category 'display_settings' -Name 'wiki_test_pref'
$null = $sb.AppendLine("### Get a single preference by category and name")
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Get-MMPreference -Category 'display_settings' -Name 'wiki_test_pref'")
$null = $sb.AppendLine()
$null = $sb.AppendLine((fmtl $singlePref))
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Remove-MMPreferences
Remove-MMPreferences -Preferences @($testPref) -Confirm:$false
$null = $sb.AppendLine('### Delete user preferences')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine("PS> Remove-MMPreferences -Preferences @(@{ user_id = '<me>'; category = 'display_settings'; name = 'wiki_test_pref'; value = 'test_value' })")
$null = $sb.AppendLine('```')

Update-WikiPage -FileName '16.-Preferences.md' -ExamplesContent $sb.ToString()
Write-Host 'Done.'
