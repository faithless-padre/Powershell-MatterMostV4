# Retrieves personal access tokens for a MatterMost user

function Get-MMUserToken {
    <#
    .SYNOPSIS
        Gets personal access tokens. Returns tokens for a user or a single token by ID.
    .DESCRIPTION
        Retrieves personal access tokens (PATs) from MatterMost.
        Use -UserId to list all tokens for a user (paginated), or -TokenId to fetch a specific token by its ID.
        Note: the actual token value is only returned at creation time (New-MMUserToken) and cannot be retrieved later.
    .PARAMETER UserId
        The ID of the user whose tokens to list. Accepts pipeline input by property name (id, user_id).
    .PARAMETER Page
        The page number for paginated results (0-based). Default is 0.
    .PARAMETER PerPage
        The number of tokens per page. Default is 60.
    .PARAMETER TokenId
        The ID of a specific token to fetch. Used with the ById parameter set.
    .OUTPUTS
        MMUserToken. One or more personal access token objects.
    .EXAMPLE
        Get-MMUserToken -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'john' | Get-MMUserToken
    .EXAMPLE
        Get-MMUserToken -TokenId 'tok123'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByUser')]
    [OutputType('MMUserToken')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByUser', ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId,

        [Parameter(ParameterSetName = 'ByUser')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'ByUser')]
        [int]$PerPage = 60,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$TokenId
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "users/tokens/$TokenId" -Method GET | ConvertTo-MMUserToken
        } else {
            Invoke-MMRequest -Endpoint "users/$UserId/tokens?page=$Page&per_page=$PerPage" -Method GET |
                ForEach-Object { $_ | ConvertTo-MMUserToken }
        }
    }
}
