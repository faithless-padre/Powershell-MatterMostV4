# Revokes a MatterMost personal access token

function Revoke-MMUserToken {
    <#
    .SYNOPSIS
        Revokes a MatterMost personal access token and deletes any sessions using it.
    .DESCRIPTION
        Sends POST /users/tokens/revoke with the token ID to permanently invalidate a personal access token.
        Any active sessions authenticated with this token are also terminated immediately.
        This action cannot be undone — a new token must be created if needed.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER TokenId
        The ID of the personal access token to revoke. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
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
