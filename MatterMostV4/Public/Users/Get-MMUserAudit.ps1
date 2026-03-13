# Получение записей аудита пользователя MatterMost

function Get-MMUserAudit {
    <#
    .SYNOPSIS
        Возвращает записи аудита пользователя MatterMost (GET /users/{id}/audits).
    .EXAMPLE
        Get-MMUserAudit -UserId 'abc123'
    .EXAMPLE
        Get-MMUser admin | Get-MMUserAudit
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/audits"
    }
}
