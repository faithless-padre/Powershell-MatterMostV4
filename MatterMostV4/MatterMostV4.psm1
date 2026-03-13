$ModuleRoot = $PSScriptRoot
$script:MMSession = $null

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

$PublicFunctions = Get-ChildItem -Path (Join-Path $ModuleRoot 'Public') -Filter '*.ps1' -Recurse |
    ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) }

Export-ModuleMember -Function $PublicFunctions
