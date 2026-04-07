# Сброс аватара пользователя MatterMost к дефолтному

function Remove-MMUserProfileImage {
    <#
    .SYNOPSIS
        Resets a MatterMost user's profile image to the auto-generated default.
    .DESCRIPTION
        Sends DELETE /users/{user_id}/image to remove the custom profile image.
        The user's avatar reverts to the system-generated default (initials-based).
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER UserId
        The ID of the user whose profile image to reset. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void
    .EXAMPLE
        Remove-MMUserProfileImage -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUserProfileImage
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Reset profile image to default')) {
            Invoke-MMRequest -Endpoint "users/$UserId/image" -Method DELETE | Out-Null
        }
    }
}
