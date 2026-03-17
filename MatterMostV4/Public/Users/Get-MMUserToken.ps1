# Retrieves personal access tokens for a MatterMost user

function Get-MMUserToken {
    <#
    .SYNOPSIS
        Gets personal access tokens. Returns tokens for a user or a single token by ID.
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
