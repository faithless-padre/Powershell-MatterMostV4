# Regenerates the token for an outgoing webhook in MatterMost

function Reset-MMOutgoingWebhookToken {
    <#
    .SYNOPSIS
        Regenerates the security token for a MatterMost outgoing webhook.
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
