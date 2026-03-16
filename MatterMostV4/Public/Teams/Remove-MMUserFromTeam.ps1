# Удаление пользователя из команды MatterMost

function Remove-MMUserFromTeam {
    <#
    .SYNOPSIS
        Removes a user from a MatterMost team.
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
