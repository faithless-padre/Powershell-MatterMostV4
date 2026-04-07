# Retrieves server log entries from MatterMost

function Get-MMServerLogs {
    <#
    .SYNOPSIS
        Gets server log entries from MatterMost.
    .DESCRIPTION
        Sends a GET request to /logs with optional pagination and filtering parameters.
        Returns an array of log line strings. Requires manage_system permission.
    .PARAMETER Page
        Page number to retrieve (zero-based). Default: 0.
    .PARAMETER PerPage
        Number of log entries per page. Default: 100.
    .PARAMETER Levels
        Comma-separated list of log levels to filter by (e.g. 'debug,info,warn,error').
    .PARAMETER LogFile
        Name of the log file to read from.
    .OUTPUTS
        System.String[]. Array of log line strings.
    .EXAMPLE
        Get-MMServerLogs -PerPage 50
    .EXAMPLE
        Get-MMServerLogs -Levels 'error,warn' -PerPage 200
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 100,

        [Parameter()]
        [string]$Levels,

        [Parameter()]
        [string]$LogFile
    )

    process {
        $query = "logs?page=$Page&per_page=$PerPage"
        if ($Levels)  { $query += "&levels=$([Uri]::EscapeDataString($Levels))" }
        if ($LogFile) { $query += "&log_file=$([Uri]::EscapeDataString($LogFile))" }

        Invoke-MMRequest -Endpoint $query
    }
}
