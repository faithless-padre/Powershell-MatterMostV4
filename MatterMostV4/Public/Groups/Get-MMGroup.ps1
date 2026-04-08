# Получение группы (LDAP/custom) MatterMost

function Get-MMGroup {
    <#
    .SYNOPSIS
        Возвращает группу MatterMost по ID или список групп с фильтрацией.
    .EXAMPLE
        Get-MMGroup
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123'
    .EXAMPLE
        Get-MMGroup -Q 'devs' -FilterAllowReference
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$GroupId,

        [Parameter(ParameterSetName = 'All')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'All')]
        [int]$PerPage = 60,

        [Parameter(ParameterSetName = 'All')]
        [string]$Q,

        [Parameter(ParameterSetName = 'All')]
        [switch]$FilterAllowReference
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "groups/$GroupId" -Method GET
            return
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($Q)                  { $query += "&q=$([uri]::EscapeDataString($Q))" }
        if ($FilterAllowReference) { $query += '&filter_allow_reference=true' }

        Invoke-MMRequest -Endpoint "groups?$query" -Method GET
    }
}
