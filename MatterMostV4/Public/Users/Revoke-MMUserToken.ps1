# Revokes a MatterMost personal access token

function Revoke-MMUserToken {
    <#
    .SYNOPSIS
        Revokes a MatterMost personal access token and deletes any sessions using it.
    .EXAMPLE
        Revoke-MMUserToken -TokenId 'tok123'
    .EXAMPLE
        Get-MMUserToken -UserId 'abc123' | Revoke-MMUserToken
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TokenId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TokenId, 'Revoke user access token')) {
            Invoke-MMRequest -Endpoint 'users/tokens/revoke' -Method POST -Body @{ token_id = $TokenId } | Out-Null
        }
    }
}
