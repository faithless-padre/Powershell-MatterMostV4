# Получение списка участников команды MatterMost

function Get-MMTeamMembers {
    <#
    .SYNOPSIS
        Returns the list of members for a MatterMost team.
    .DESCRIPTION
        Retrieves all team members from /teams/{team_id}/members with automatic pagination (200 per page).
        Returns MMTeamMember objects containing user ID, roles, and scheme flags — not full user profiles.
        Use Get-MMUser to enrich the results with user details.
    .PARAMETER TeamId
        The ID of the team. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER TeamName
        The name of the team. Used with the ByName parameter set.
    .OUTPUTS
        MMTeamMember. One or more team membership objects.
    .EXAMPLE
        Get-MMTeamMembers -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeamMembers -TeamName 'myteam'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Get-MMTeamMembers
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMTeamMember')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$TeamName
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMTeam -Name $TeamName).id
        } else {
            $TeamId
        }

        $page    = 0
        $perPage = 200
        do {
            $batch = Invoke-MMRequest -Endpoint "teams/$resolvedId/members?page=$page&per_page=$perPage"
            $batch | ConvertTo-MMTeamMember
            $page++
        } while ($batch.Count -eq $perPage)
    }
}
