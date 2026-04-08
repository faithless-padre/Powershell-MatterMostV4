# Сброс и перегенерация invite_id команды MatterMost

function Reset-MMTeamInvite {
    <#
    .SYNOPSIS
        Regenerates the invite ID for a MatterMost team. Returns updated MMTeam object.
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .EXAMPLE
        Reset-MMTeamInvite -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Reset-MMTeamInvite
    #>
    [OutputType('MMTeam')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TeamId, 'Regenerate team invite ID')) {
            Invoke-MMRequest -Endpoint "teams/$TeamId/regenerate_invite_id" -Method POST | ConvertTo-MMTeam
        }
    }
}
