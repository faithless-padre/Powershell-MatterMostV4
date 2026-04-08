# Включение плагина в MatterMost

function Enable-MMPlugin {
    <#
    .SYNOPSIS
        Enables an installed plugin on MatterMost.
    .EXAMPLE
        Enable-MMPlugin -PluginId 'com.example.myplugin'
    .EXAMPLE
        (Get-MMPlugin).inactive | Where-Object id -eq 'com.example.myplugin' | Enable-MMPlugin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PluginId
    )

    process {
        Invoke-MMRequest -Endpoint "plugins/$PluginId/enable" -Method POST | Out-Null
    }
}
