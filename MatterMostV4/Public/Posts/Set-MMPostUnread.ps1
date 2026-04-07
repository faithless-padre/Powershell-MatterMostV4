# Помечает пост как непрочитанный для пользователя MatterMost

function Set-MMPostUnread {
    <#
    .SYNOPSIS
        Marks a MatterMost post as unread for the specified user.
    .DESCRIPTION
        Calls POST /users/{user_id}/posts/{post_id}/set_unread so the channel appears
        with an unread indicator starting from that post. Defaults to the current user.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER PostId
        The ID of the post to mark as unread. Accepts pipeline input by property name (id).
    .PARAMETER UserId
        The user for whom the post is marked unread. Defaults to the current authenticated user.
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Set-MMPostUnread -PostId 'abc123'
    .EXAMPLE
        Get-MMPost -PostId 'abc123' | Set-MMPostUnread
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

        if ($PSCmdlet.ShouldProcess($PostId, 'Mark post as unread')) {
            Invoke-MMRequest -Endpoint "users/$UserId/posts/$PostId/set_unread" -Method POST -Body @{} | Out-Null
        }
    }
}
