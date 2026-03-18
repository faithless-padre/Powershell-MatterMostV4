# Отзыв конкретной сессии пользователя MatterMost

function Revoke-MMUserSession {
    <#
    .SYNOPSIS
        Revokes the specified MatterMost user session.
    .DESCRIPTION
        Sends POST /users/{user_id}/sessions/revoke to terminate a single specific session by ID.
        The user is logged out from that device or client only. Other sessions remain active.
        Pipe from Get-MMUserSession to revoke specific sessions by type (e.g., only mobile sessions).
        Requires admin permissions.
    .PARAMETER UserId
        The ID of the user who owns the session. Accepts pipeline input by property name (user_id).
    .PARAMETER SessionId
        The ID of the session to revoke. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Revoke-MMUserSession -UserId 'abc123' -SessionId 'sess456'
    .EXAMPLE
        Get-MMUserSession -UserId 'abc123' | Revoke-MMUserSession
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('user_id')]
        [string]$UserId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$SessionId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/sessions/revoke" -Method POST -Body @{
            session_id = $SessionId
        } | Out-Null
    }
}
