# Deletes an incoming webhook from MatterMost

function Remove-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Deletes a MatterMost incoming webhook by ID.
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
