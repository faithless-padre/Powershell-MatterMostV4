# Deletes an outgoing webhook from MatterMost

function Remove-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Deletes a MatterMost outgoing webhook by ID.
    .DESCRIPTION
        Sends DELETE /hooks/outgoing/{hook_id} to permanently remove the outgoing webhook.
        After deletion, the webhook will no longer fire on trigger words.
        Supports ShouldProcess (-WhatIf / -Confirm). Requires admin permissions or webhook ownership.
    .PARAMETER HookId
        The ID of the outgoing webhook to delete. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMOutgoingWebhook -HookId 'abc123'
    .EXAMPLE
        Get-MMOutgoingWebhook -TeamName 'my-team' | Remove-MMOutgoingWebhook
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$HookId
    )

    process {
        if ($PSCmdlet.ShouldProcess($HookId, 'Remove outgoing webhook')) {
            Invoke-MMRequest -Endpoint "hooks/outgoing/$HookId" -Method DELETE | Out-Null
        }
    }
}
