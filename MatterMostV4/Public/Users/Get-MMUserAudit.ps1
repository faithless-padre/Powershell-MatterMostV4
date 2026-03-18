# Получение записей аудита пользователя MatterMost

function Get-MMUserAudit {
    <#
    .SYNOPSIS
        Returns audit log entries for a MatterMost user (GET /users/{id}/audits).
    .DESCRIPTION
        Calls GET /users/{user_id}/audits to retrieve the audit trail for the specified user.
        Each entry includes the action performed, timestamp, IP address, and session details.
        Useful for security reviews and compliance auditing. Requires admin permissions.
    .PARAMETER UserId
        The ID of the user whose audit log to retrieve. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Object. Raw audit log entries as returned by the API (no custom type conversion).
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
