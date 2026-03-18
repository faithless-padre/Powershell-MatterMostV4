# Получение списка участников команды MatterMost

function Get-MMTeamMembers {
    <#
    .SYNOPSIS
        Returns the list of members for a MatterMost team.
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
