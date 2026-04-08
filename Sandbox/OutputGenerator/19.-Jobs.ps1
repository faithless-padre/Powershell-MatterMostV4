# Генератор реального вывода для wiki-страницы Jobs API

. (Join-Path $PSScriptRoot 'Common.ps1')

Connect-Sandbox

$sb = [System.Text.StringBuilder]::new()

# Get-MMJob (list all)
$jobs = Get-MMJob
$null = $sb.AppendLine('### List all jobs')
$null = $sb.AppendLine('```powershell')
$null = $sb.AppendLine('PS> Get-MMJob')
$null = $sb.AppendLine()
if ($jobs -and @($jobs).Count -gt 0) {
    $null = $sb.AppendLine((fmtt ($jobs | Select-Object -First 5)))
} else {
    $null = $sb.AppendLine('(no jobs found)')
}
$null = $sb.AppendLine('```')
$null = $sb.AppendLine()

# Get-MMJob -JobId (first job if exists)
if ($jobs -and @($jobs).Count -gt 0) {
    $firstJob = @($jobs)[0]
    $jobById = Get-MMJob -JobId $firstJob.Id
    $null = $sb.AppendLine('### Get a specific job by ID')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Get-MMJob -JobId '$($firstJob.Id)'")
    $null = $sb.AppendLine()
    $null = $sb.AppendLine((fmtl $jobById))
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()

    # Get-MMJobsByType — use type from first job
    $firstType = $firstJob.Type
    $null = $sb.AppendLine("### Get jobs by type")
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Get-MMJobsByType -Type '$firstType'")
    $null = $sb.AppendLine()
    $byType = Get-MMJobsByType -Type $firstType
    if ($byType -and @($byType).Count -gt 0) {
        $null = $sb.AppendLine((fmtt ($byType | Select-Object -First 5)))
    } else {
        $null = $sb.AppendLine('(no jobs of this type found)')
    }
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()
} else {
    # No jobs — just show syntax examples
    $null = $sb.AppendLine('### Get a specific job by ID')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Get-MMJob -JobId '<job-id>'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()

    $null = $sb.AppendLine('### Get jobs by type')
    $null = $sb.AppendLine('```powershell')
    $null = $sb.AppendLine("PS> Get-MMJobsByType -Type 'ldap_sync'")
    $null = $sb.AppendLine('```')
    $null = $sb.AppendLine()
}

# Handle wiki path: inside docker the host path doesn't exist, write to stdout instead
if (Test-Path $script:WikiPath) {
    Update-WikiPage -FileName '19.-Jobs.md' -ExamplesContent $sb.ToString()
} else {
    Write-Host '--- Wiki output (WikiPath not available) ---'
    Write-Host $sb.ToString()
}
Write-Host 'Done.'
