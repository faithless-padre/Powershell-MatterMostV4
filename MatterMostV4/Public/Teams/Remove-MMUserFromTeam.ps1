# Удаление пользователя из команды MatterMost

function Remove-MMUserFromTeam {
    <#
    .SYNOPSIS
        Removes a user from a MatterMost team.
    .DESCRIPTION
        Sends DELETE /teams/{team_id}/members/{user_id} to remove the user's membership.
        If -TeamId is omitted, falls back to the default team set via Connect-MMServer -DefaultTeam.
        The user account itself is not affected. Supports ShouldProcess (-WhatIf / -Confirm).
    .PARAMETER TeamId
        The ID of the team to remove the user from. Falls back to the default team if omitted.
    .PARAMETER UserId
        The ID of the user to remove. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Remove-MMUserFromTeam -TeamId 'team123' -UserId 'user123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Remove-MMUserFromTeam -TeamId 'team123'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$TeamId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }
        if ($PSCmdlet.ShouldProcess($UserId, "Remove from team $resolvedTeamId")) {
            Invoke-MMRequest -Endpoint "teams/$resolvedTeamId/members/$UserId" -Method DELETE
        }
    }
}
