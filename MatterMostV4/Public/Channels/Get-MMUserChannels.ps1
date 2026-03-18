# Получение списка каналов пользователя в команде MatterMost

function Get-MMUserChannels {
    <#
    .SYNOPSIS
        Returns the list of channels a user belongs to in a MatterMost team.
    .DESCRIPTION
        Calls /users/{user_id}/teams/{team_id}/channels to retrieve all channels the specified user
        is a member of within the given team. Supports lookup by ID or by username/team name.
    .PARAMETER UserId
        The ID of the user. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER TeamId
        The ID of the team. Used with the ById parameter set.
    .PARAMETER Username
        The username of the user. Used with the ByName parameter set.
    .PARAMETER TeamName
        The name of the team. Used with the ByName parameter set.
    .OUTPUTS
        MMChannel. One or more channel objects the user belongs to.
    .EXAMPLE
        Get-MMUserChannels -UserId 'user123' -TeamId 'team456'
    .EXAMPLE
        Get-MMUserChannels -Username 'jdoe' -TeamName 'my-team'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserChannels -TeamName 'my-team'
    #>
    [OutputType('MMChannel')]
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Username,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$TeamName
    )

    process {
        $resolvedUserId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMUser -Username $Username).id
        } else {
            $UserId
        }

        $resolvedTeamId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMTeam -Name $TeamName).id
        } else {
            $TeamId
        }

        Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels" | ConvertTo-MMChannel
    }
}
