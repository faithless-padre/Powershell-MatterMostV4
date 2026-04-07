# Retrieves the list of supported IANA timezones from MatterMost

function Get-MMServerTimezones {
    <#
    .SYNOPSIS
        Gets the list of supported IANA timezone names from the MatterMost server.
    .DESCRIPTION
        Sends a GET request to /system/timezones and returns an array of timezone strings.
    .OUTPUTS
        System.String[]. Array of IANA timezone name strings.
    .EXAMPLE
        Get-MMServerTimezones
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'system/timezones'
    }
}
