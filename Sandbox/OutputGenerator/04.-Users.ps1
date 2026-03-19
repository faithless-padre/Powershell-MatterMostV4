# Generates examples with output for Users wiki page
. (Join-Path $PSScriptRoot 'Common.ps1')
Connect-Sandbox

$ex = @()

# Get-MMUser (me)
$me = Get-MMUser
$ex += block 'Get-MMUser' (fmtl $me)

# Get-MMUser -Username
$testUser = Get-MMUser -Username $MM_TESTUSER
$ex += block "Get-MMUser -Username '$MM_TESTUSER'" (fmtl $testUser)

# Get-MMUser -All
$all = Get-MMUser -All
$ex += block 'Get-MMUser -All' (fmtt $all)

# Get-MMUser -Filter
$filtered = Get-MMUser -Filter {username -like 'test*'}
$ex += block "Get-MMUser -Filter {username -like 'test*'}" (fmtt $filtered)

# Get-MMUserStats
$stats = Get-MMUserStats
$ex += block 'Get-MMUserStats' (fmtl $stats)

# New-MMUser
$rnd = Get-Random -Minimum 1000 -Maximum 9999
$newPass = ConvertTo-SecureString 'NewUser123!' -AsPlainText -Force
$newUser = New-MMUser -Username "demouser$rnd" -Email "demo$rnd@test.local" -FirstName 'Demo' -LastName 'User' -Password $newPass
$ex += block "New-MMUser -Username 'demouser' -Email 'demo@test.local' -FirstName 'Demo' -LastName 'User' -Password `$pass" (fmtl $newUser)

# Get-MMUserSession
$sessions = Get-MMUserSession -UserId $me.Id
$ex += block "Get-MMUser | Get-MMUserSession" (fmtt $sessions)

# Get-MMUserAudit
$audit = Get-MMUserAudit -UserId $me.Id | Select-Object -First 3
$ex += block "Get-MMUser | Get-MMUserAudit | Select-Object -First 3" (fmtt $audit)

# Cleanup
Remove-MMUser -UserId $newUser.Id | Out-Null

Update-WikiPage '04.-Users.md' ($ex -join "`n`n")
Disconnect-MMServer | Out-Null
