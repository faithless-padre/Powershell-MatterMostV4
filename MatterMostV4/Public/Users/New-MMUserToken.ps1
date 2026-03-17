# Creates a personal access token for a MatterMost user

function New-MMUserToken {
    <#
    .SYNOPSIS
        Creates a personal access token for a MatterMost user.
    .EXAMPLE
        New-MMUserToken -UserId 'abc123' -Description 'CI/CD bot token'
    .EXAMPLE
        Get-MMUser -Username 'john' | New-MMUserToken -Description 'Automation token'
    #>
    [CmdletBinding()]
    [OutputType('MMUserToken')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$Description
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/tokens" -Method POST -Body @{ description = $Description } |
            ConvertTo-MMUserToken
    }
}
