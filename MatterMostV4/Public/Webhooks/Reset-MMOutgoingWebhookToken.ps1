# Regenerates the token for an outgoing webhook in MatterMost

function Reset-MMOutgoingWebhookToken {
    <#
    .SYNOPSIS
        Regenerates the security token for a MatterMost outgoing webhook.
    .DESCRIPTION
        Sends POST /hooks/outgoing/{hook_id}/regen_token to rotate the webhook's verification token.
        The new token is included in every outgoing request so the receiver can verify the request is authentic.
        Use this if the token is compromised. Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER HookId
        The ID of the outgoing webhook whose token to regenerate. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Reset-MMOutgoingWebhookToken -HookId 'abc123'
    .EXAMPLE
        Get-MMOutgoingWebhook -HookId 'abc123' | Reset-MMOutgoingWebhookToken
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$HookId
    )

    process {
        if ($PSCmdlet.ShouldProcess($HookId, 'Regenerate outgoing webhook token')) {
            Invoke-MMRequest -Endpoint "hooks/outgoing/$HookId/regen_token" -Method POST | Out-Null
        }
    }
}
