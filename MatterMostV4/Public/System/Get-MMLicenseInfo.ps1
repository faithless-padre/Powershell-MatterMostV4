# Retrieves client-facing license information from MatterMost

function Get-MMLicenseInfo {
    <#
    .SYNOPSIS
        Gets the client-facing license information from MatterMost.
    .DESCRIPTION
        Sends a GET request to /license/client?format=old and returns the license
        fields such as IsLicensed, IsTrialLicense, SkuName, and Company.
    .OUTPUTS
        PSCustomObject. License information object.
    .EXAMPLE
        Get-MMLicenseInfo
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param()

    process {
        Invoke-MMRequest -Endpoint 'license/client?format=old'
    }
}
