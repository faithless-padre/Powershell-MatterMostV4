# Добавление пользователя в команду MatterMost

function Add-MMUserToTeam {
    <#
    .SYNOPSIS
        Добавляет пользователя в команду MatterMost.
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
