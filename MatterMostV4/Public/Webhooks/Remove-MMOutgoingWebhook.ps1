# Deletes an outgoing webhook from MatterMost

function Remove-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Deletes a MatterMost outgoing webhook by ID.
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
