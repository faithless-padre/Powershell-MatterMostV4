# Восстановление удалённой (архивированной) команды MatterMost

function Restore-MMTeam {
    <#
    .SYNOPSIS
        Restores a deleted (archived) MatterMost team.
    .DESCRIPTION
        Sends POST /teams/{team_id}/restore to un-archive a previously deleted team.
        All channels and members are preserved and restored to active status.
        Requires system admin permissions.
    .PARAMETER TeamId
        The ID of the team to restore. Accepts pipeline input by property name (id).
    .OUTPUTS
        MMTeam. The restored team object.
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
