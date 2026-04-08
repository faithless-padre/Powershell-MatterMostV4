# Получение задания (job) MatterMost

function Get-MMJob {
    <#
    .SYNOPSIS
        Возвращает задание MatterMost по ID или список заданий.
    .EXAMPLE
        Get-MMJob
    .EXAMPLE
        Get-MMJob -JobId 'abc123'
    .EXAMPLE
        Get-MMJob -Page 1 -PerPage 20
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$JobId,

        [Parameter(ParameterSetName = 'All')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'All')]
        [int]$PerPage = 60
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "jobs/$JobId" -Method GET
            return
        }

        $query = "page=$Page&per_page=$PerPage"
        Invoke-MMRequest -Endpoint "jobs?$query" -Method GET
    }
}
