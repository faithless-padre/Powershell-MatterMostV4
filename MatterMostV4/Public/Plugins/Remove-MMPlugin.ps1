# Удаление плагина из MatterMost

function Remove-MMPlugin {
    <#
    .SYNOPSIS
        Removes an installed plugin from MatterMost.
    .EXAMPLE
        Remove-MMPlugin -PluginId 'com.example.myplugin'
    .EXAMPLE
        (Get-MMPlugin).inactive | Where-Object id -eq 'com.example.myplugin' | Remove-MMPlugin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PluginId
    )

    process {
        Invoke-MMRequest -Endpoint "plugins/$PluginId" -Method DELETE | Out-Null
    }
}
