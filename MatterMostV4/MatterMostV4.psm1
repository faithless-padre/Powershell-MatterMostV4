$ModuleRoot = $PSScriptRoot
$script:MMSession = $null

# Classes must be loaded first — cmdlets depend on them
$ClassesPath = Join-Path -Path $ModuleRoot -ChildPath 'Classes'
if (Test-Path -Path $ClassesPath) {
    Get-ChildItem -Path $ClassesPath -Filter '*.ps1' | ForEach-Object {
        . $_.FullName
    }
}

foreach ($Folder in @('Private', 'Public')) {
    $FolderPath = Join-Path -Path $ModuleRoot -ChildPath $Folder
    if (Test-Path -Path $FolderPath) {
        Get-ChildItem -Path $FolderPath -Filter '*.ps1' -Recurse | ForEach-Object {
            try {
                . $_.FullName
            }
            catch {
                Write-Error "Failed to import function $($_.FullName): $_"
            }
        }
    }
}
