# Снимает подтверждение (acknowledge) с поста MatterMost

function Remove-MMPostAcknowledgement {
    <#
    .SYNOPSIS
        Removes a user's acknowledgement from a MatterMost post.
    .DESCRIPTION
        Calls DELETE /users/{user_id}/posts/{post_id}/ack to retract a previously
        submitted acknowledgement. Supports ShouldProcess (-WhatIf / -Confirm).
        Defaults to the current authenticated user.
    .PARAMETER PostId
        The ID of the post to remove the acknowledgement from. Accepts pipeline input by property name (id).
    .PARAMETER UserId
        The user whose acknowledgement to remove. Defaults to the current authenticated user.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMPostAcknowledgement -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Remove-MMPostAcknowledgement
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$PostId,

        [Parameter()]
        [string]$UserId
    )

    process {
        if (-not $UserId) {
            $UserId = (Invoke-MMRequest -Endpoint 'users/me').id
        }

        if ($PSCmdlet.ShouldProcess($PostId, 'Remove post acknowledgement')) {
            Invoke-MMRequest -Endpoint "users/$UserId/posts/$PostId/ack" -Method DELETE
        }
    }
}
