# Removes a user's custom status in MatterMost

function Remove-MMUserCustomStatus {
    <#
    .SYNOPSIS
        Clears a MatterMost user's custom status.
    .DESCRIPTION
        Sends DELETE /users/{user_id}/status/custom to remove any custom status (emoji + text)
        set by the user. The base status (online/away/dnd/offline) is not affected.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER UserId
        The ID of the user whose custom status to clear. Accepts pipeline input by property name (id, user_id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMUserCustomStatus -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'john' | Remove-MMUserCustomStatus
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id', 'user_id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Remove custom status')) {
            Invoke-MMRequest -Endpoint "users/$UserId/status/custom" -Method DELETE | Out-Null
        }
    }
}
