# Retrieves the full MatterMost server configuration

function Get-MMServerConfig {
    <#
    .SYNOPSIS
        Gets the full MatterMost server configuration.
    .DESCRIPTION
        Sends a GET request to /config and returns the entire server configuration object.
        Requires manage_system permission (admin only).
    .OUTPUTS
        PSCustomObject. The full server configuration.
    .EXAMPLE
        Get-MMServerConfig
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'config'
    }
}
