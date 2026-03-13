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
        [Parameter(Mandatory)]
        [string]$TeamId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "teams/$TeamId/members" -Method POST -Body @{ team_id = $TeamId; user_id = $UserId }
    }
}
