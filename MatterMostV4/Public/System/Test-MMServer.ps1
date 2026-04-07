# Checks MatterMost server health via /system/ping

function Test-MMServer {
    <#
    .SYNOPSIS
        Checks the health of the MatterMost server.
    .DESCRIPTION
        Sends a GET request to /system/ping and returns the server health status,
        including database_status, filestore_status, and active_search_backend.
    .OUTPUTS
        PSCustomObject. Raw server ping response.
    .EXAMPLE
        Test-MMServer
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'system/ping'
    }
}
