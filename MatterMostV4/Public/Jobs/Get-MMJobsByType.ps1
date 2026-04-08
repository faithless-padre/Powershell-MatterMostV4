# Получение заданий MatterMost по типу

function Get-MMJobsByType {
    <#
    .SYNOPSIS
        Возвращает список заданий MatterMost указанного типа.
    .EXAMPLE
        Get-MMJobsByType -Type 'ldap-sync'
    .EXAMPLE
        Get-MMJobsByType -Type 'message-export' -Page 1 -PerPage 20
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Type,

        [int]$Page = 0,

        [int]$PerPage = 60
    )

    process {
        $query = "page=$Page&per_page=$PerPage"
        Invoke-MMRequest -Endpoint "jobs/type/$([uri]::EscapeDataString($Type))?$query" -Method GET
    }
}
