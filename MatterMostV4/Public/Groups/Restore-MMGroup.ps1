# Восстановление удалённой группы MatterMost

function Restore-MMGroup {
    <#
    .SYNOPSIS
        Восстанавливает удалённую группу MatterMost.
    .EXAMPLE
        Restore-MMGroup -GroupId 'abc123'
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Restore-MMGroup
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId
    )

    process {
        Invoke-MMRequest -Endpoint "groups/$GroupId/restore" -Method POST
    }
}
