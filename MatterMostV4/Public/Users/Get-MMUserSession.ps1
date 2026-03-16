# Получение активных сессий пользователя MatterMost

function Get-MMUserSession {
    <#
    .SYNOPSIS
        Returns the list of active sessions for a MatterMost user.
    .EXAMPLE
        Get-MMUserSession -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserSession
    #>
    [OutputType('MMSession')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/sessions" | ConvertTo-MMSession
    }
}
