# Получение статистики группы MatterMost

function Get-MMGroupStats {
    <#
    .SYNOPSIS
        Возвращает статистику группы MatterMost (group_id, total_member_count).
    .EXAMPLE
        Get-MMGroupStats -GroupId 'abc123'
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Get-MMGroupStats
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId
    )

    process {
        Invoke-MMRequest -Endpoint "groups/$GroupId/stats" -Method GET
    }
}
