# Получение статусов плагинов MatterMost по всем нодам кластера

function Get-MMPluginStatus {
    <#
    .SYNOPSIS
        Returns the status of all plugins across cluster nodes.
        State values: 0 = not running, 1 = starting, 2 = running, 3 = failing.
    .EXAMPLE
        Get-MMPluginStatus
    .EXAMPLE
        Get-MMPluginStatus | Where-Object state -eq 3
    #>
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'plugins/statuses' -Method GET
    }
}
