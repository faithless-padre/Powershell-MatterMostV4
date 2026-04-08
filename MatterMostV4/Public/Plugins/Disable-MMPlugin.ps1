# Отключение плагина в MatterMost

function Disable-MMPlugin {
    <#
    .SYNOPSIS
        Disables an active plugin on MatterMost.
    .EXAMPLE
        Disable-MMPlugin -PluginId 'com.example.myplugin'
    .EXAMPLE
        (Get-MMPlugin).active | Where-Object id -eq 'com.example.myplugin' | Disable-MMPlugin
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PluginId
    )

    process {
        Invoke-MMRequest -Endpoint "plugins/$PluginId/disable" -Method POST | Out-Null
    }
}
