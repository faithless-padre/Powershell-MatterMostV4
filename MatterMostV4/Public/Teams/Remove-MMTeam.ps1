# Удаление (архивирование) команды MatterMost

function Remove-MMTeam {
    <#
    .SYNOPSIS
        Archives a MatterMost team.
    .DESCRIPTION
        Sends DELETE /teams/{team_id} to soft-archive the team. The team is not permanently deleted —
        it can be restored with Restore-MMTeam. All channels and messages are preserved.
        Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER TeamId
        The ID of the team to archive. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Remove-MMTeam
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TeamId, 'Archive team')) {
            Invoke-MMRequest -Endpoint "teams/$TeamId" -Method DELETE
        }
    }
}
