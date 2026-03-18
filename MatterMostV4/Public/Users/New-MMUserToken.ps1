# Creates a personal access token for a MatterMost user

function New-MMUserToken {
    <#
    .SYNOPSIS
        Creates a personal access token for a MatterMost user.
    .DESCRIPTION
        Sends POST /users/{user_id}/tokens to generate a new personal access token (PAT).
        The token value is included in the response and can be used as a Bearer token for API calls.
        Important: the token value is only returned once at creation — save it immediately.
        The PAT feature must be enabled on the server. Requires admin permissions to create tokens for other users.
    .PARAMETER UserId
        The ID of the user to create the token for. Accepts pipeline input by property name (id, user_id).
    .PARAMETER Description
        A human-readable description for the token, e.g. 'CI/CD automation' or 'PowerShell script'.
    .OUTPUTS
        MMUserToken. The created token object including the token value (only available at creation time).
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
