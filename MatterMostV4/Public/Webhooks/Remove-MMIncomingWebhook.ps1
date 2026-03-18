# Deletes an incoming webhook from MatterMost

function Remove-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Deletes a MatterMost incoming webhook by ID.
    .DESCRIPTION
        Sends DELETE /hooks/incoming/{hook_id} to permanently remove the incoming webhook.
        After deletion, any integrations using this webhook's URL will stop receiving messages.
        Supports ShouldProcess (-WhatIf / -Confirm). Requires admin permissions or webhook ownership.
    .PARAMETER HookId
        The ID of the incoming webhook to delete. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMIncomingWebhook -HookId 'abc123'
    .EXAMPLE
        Get-MMIncomingWebhook -TeamName 'my-team' | Remove-MMIncomingWebhook
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$HookId
    )

    process {
        if ($PSCmdlet.ShouldProcess($HookId, 'Remove incoming webhook')) {
            Invoke-MMRequest -Endpoint "hooks/incoming/$HookId" -Method DELETE | Out-Null
        }
    }
}
