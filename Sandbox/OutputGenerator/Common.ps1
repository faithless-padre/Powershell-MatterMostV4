# Shared helpers for wiki output generators

$script:WikiPath   = '/home/padre/MMv4/Wiki'
$script:ModulePath = '/home/padre/MMv4/MatterMost/MatterMostV4/MatterMostV4.psd1'

$MM_URL      = if ($env:MM_URL)            { $env:MM_URL }            else { 'http://localhost:8065' }
$MM_USER     = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { 'admin' }
$MM_PASS     = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { 'Admin123456!' }
$MM_TESTUSER = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { 'testuser' }
$MM_TEAM     = if ($env:MM_TEST_TEAM)      { $env:MM_TEST_TEAM }      else { 'testteam' }

function Connect-Sandbox {
    Import-Module $script:ModulePath -Force
    $sec = ConvertTo-SecureString $MM_PASS -AsPlainText -Force
    Connect-MMServer -Url $MM_URL -Username $MM_USER -Password $sec -DefaultTeam $MM_TEAM | Out-Null
}

function fmtl($obj) {
    if ($null -eq $obj) { return '(no output)' }
    ($obj | Format-List | Out-String).TrimEnd()
}

function fmtt($obj) {
    if ($null -eq $obj) { return '(no output)' }
    ($obj | Format-Table -AutoSize | Out-String).TrimEnd()
}

function Update-WikiPage {
    param([string]$FileName, [string]$ExamplesContent)

    $path = Join-Path $script:WikiPath $FileName
    $content = Get-Content $path -Raw

    $marker = '## Examples'
    $idx = $content.IndexOf($marker)
    if ($idx -lt 0) {
        Write-Warning "No '## Examples' found in $FileName"
        return
    }

    $before = $content.Substring(0, $idx)
    $newContent = $before + $marker + "`n`n" + $ExamplesContent.TrimStart()
    $newContent | Set-Content -Path $path -Encoding UTF8 -NoNewline
    Write-Host "Updated: $FileName"
}
