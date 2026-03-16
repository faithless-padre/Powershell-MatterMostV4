# Отзыв конкретной сессии пользователя MatterMost

function Revoke-MMUserSession {
    <#
    .SYNOPSIS
        Отзывает указанную сессию пользователя MatterMost.
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
