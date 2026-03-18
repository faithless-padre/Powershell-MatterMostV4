# Отзыв всех активных сессий пользователя MatterMost

function Revoke-MMAllUserSessions {
    <#
    .SYNOPSIS
        Revokes all active sessions for a MatterMost user.
    .DESCRIPTION
        Sends POST /users/{user_id}/sessions/revoke/all to terminate every active session for the user.
        The user is immediately logged out from all devices and clients.
        Use this for security incidents or when disabling accounts. Requires admin permissions.
    .PARAMETER UserId
        The ID of the user whose sessions to revoke. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Revoke-MMAllUserSessions -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Revoke-MMAllUserSessions
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/sessions/revoke/all" -Method POST | Out-Null
    }
}
