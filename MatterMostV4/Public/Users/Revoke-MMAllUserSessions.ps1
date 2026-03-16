# Отзыв всех активных сессий пользователя MatterMost

function Revoke-MMAllUserSessions {
    <#
    .SYNOPSIS
        Revokes all active sessions for a MatterMost user.
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
