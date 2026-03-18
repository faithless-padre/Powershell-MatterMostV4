# Деактивация пользователя MatterMost

function Remove-MMUser {
    <#
    .SYNOPSIS
        Deactivates a MatterMost user (soft delete).
    .DESCRIPTION
        Sends DELETE /users/{user_id} to soft-deactivate the user account.
        The user cannot log in after deactivation but all messages, channels, and data are preserved.
        This is equivalent to Disable-MMUser. Use Enable-MMUser to reactivate.
        Supports ShouldProcess (-WhatIf / -Confirm). Requires admin permissions.
    .PARAMETER UserId
        The ID of the user to deactivate. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUser
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Deactivate user')) {
            Invoke-MMRequest -Endpoint "users/$UserId" -Method DELETE
        }
    }
}
