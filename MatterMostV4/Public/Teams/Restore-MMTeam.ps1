# Восстановление удалённой (архивированной) команды MatterMost

function Restore-MMTeam {
    <#
    .SYNOPSIS
        Restores a deleted (archived) MatterMost team.
    .EXAMPLE
        Restore-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -TeamId 'abc123' | Restore-MMTeam
    #>
    [CmdletBinding()]
    [OutputType('MMTeam')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        Invoke-MMRequest -Endpoint "teams/$TeamId/restore" -Method POST |
            ConvertTo-MMTeam
    }
}
