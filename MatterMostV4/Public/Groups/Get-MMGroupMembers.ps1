# Получение участников группы MatterMost

function Get-MMGroupMembers {
    <#
    .SYNOPSIS
        Возвращает список пользователей — участников группы MatterMost.
    .EXAMPLE
        Get-MMGroupMembers -GroupId 'abc123'
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Get-MMGroupMembers -PerPage 100
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId,

        [int]$Page = 0,

        [int]$PerPage = 60
    )

    process {
        $query = "page=$Page&per_page=$PerPage"
        Invoke-MMRequest -Endpoint "groups/$GroupId/members?$query" -Method GET
    }
}
