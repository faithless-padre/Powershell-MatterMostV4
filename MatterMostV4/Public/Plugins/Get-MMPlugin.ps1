# Получение списка плагинов MatterMost

function Get-MMPlugin {
    <#
    .SYNOPSIS
        Returns all installed plugins on the MatterMost server, split into active and inactive lists.
    .EXAMPLE
        Get-MMPlugin
    .EXAMPLE
        (Get-MMPlugin).active
    #>
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'plugins' -Method GET
    }
}
