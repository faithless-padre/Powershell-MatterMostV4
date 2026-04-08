# Получение статистики команды MatterMost

function Get-MMTeamStats {
    <#
    .SYNOPSIS
        Returns statistics for a MatterMost team (total and active member count).
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .EXAMPLE
        Get-MMTeamStats -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Get-MMTeamStats
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        $raw = Invoke-MMRequest -Endpoint "teams/$TeamId/stats"

        [PSCustomObject]@{
            team_id             = $raw.team_id
            total_member_count  = $raw.total_member_count
            active_member_count = $raw.active_member_count
        }
    }
}
