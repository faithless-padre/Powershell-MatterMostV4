# Writes a custom log entry to the MatterMost server log

function Add-MMServerLogEntry {
    <#
    .SYNOPSIS
        Writes a message to the MatterMost server log.
    .DESCRIPTION
        Sends a POST request to /logs with the specified level and message.
        Requires manage_system permission.
    .PARAMETER Level
        Log level for the entry. Valid values: debug, info, warn, error.
    .PARAMETER Message
        The message text to write to the log.
    .EXAMPLE
        Add-MMServerLogEntry -Level 'info' -Message 'Deployment started'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('debug', 'info', 'warn', 'error')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    process {
        $body = @{
            level   = $Level
            message = $Message
        }
        Invoke-MMRequest -Endpoint 'logs' -Method POST -Body $body | Out-Null
    }
}
