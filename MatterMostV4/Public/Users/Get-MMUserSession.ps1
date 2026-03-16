# Получение активных сессий пользователя MatterMost

function Get-MMUserSession {
    <#
    .SYNOPSIS
        Возвращает список активных сессий пользователя MatterMost.
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
