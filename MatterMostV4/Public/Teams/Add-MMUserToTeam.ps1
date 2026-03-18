# Добавление пользователя в команду MatterMost

function Add-MMUserToTeam {
    <#
    .SYNOPSIS
        Adds a user to a MatterMost team.
    .DESCRIPTION
        Posts a membership entry to /teams/{team_id}/members. If -TeamId is omitted,
        the default team set via Connect-MMServer -DefaultTeam is used. The user must exist in the system.
    .PARAMETER TeamId
        The ID of the team to add the user to. Falls back to the default team if omitted.
    .PARAMETER UserId
        The ID of the user to add. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Add-MMUserToTeam -TeamId 'team123' -UserId 'user123'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Add-MMUserToTeam -TeamId 'team123'
    #>
    [CmdletBinding()]
    param(
        [string]$TeamId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }
        Invoke-MMRequest -Endpoint "teams/$resolvedTeamId/members" -Method POST -Body @{ team_id = $resolvedTeamId; user_id = $UserId }
    }
}
