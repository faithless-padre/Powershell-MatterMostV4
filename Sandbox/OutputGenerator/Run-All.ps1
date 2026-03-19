# Runs all output generators and updates Wiki-new pages
# Usage: pwsh Run-All.ps1
# Requires sandbox to be running (make start)

$generators = @(
    '02.-Connection.ps1'
    '03.-Posts.ps1'
    '04.-Users.ps1'
    '05.-Roles.ps1'
    '06.-Status.ps1'
    '07.-Channels.ps1'
    '08.-Teams.ps1'
    '09.-Emoji.ps1'
    '10.-Files.ps1'
    '11.-Webhooks.ps1'
    '12.-Bots.ps1'
)

$failed = @()

foreach ($gen in $generators) {
    $path = Join-Path $PSScriptRoot $gen
    Write-Host "`n=== $gen ===" -ForegroundColor Cyan
    try {
        pwsh -NoProfile -File $path
    } catch {
        Write-Warning "FAILED: $gen — $_"
        $failed += $gen
    }
}

Write-Host "`n==============================" -ForegroundColor Green
if ($failed.Count -eq 0) {
    Write-Host "All generators completed successfully." -ForegroundColor Green
} else {
    Write-Host "Failed: $($failed -join ', ')" -ForegroundColor Red
}
