# Получение списка участников команды MatterMost

function Get-MMTeamMembers {
    <#
    .SYNOPSIS
        Returns the list of members for a MatterMost team.
    .EXAMPLE
        Get-MMTeamMembers -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'myteam' | Get-MMTeamMembers
    #>
    [CmdletBinding()]
    [OutputType('MMTeamMember')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId
    )

    process {
        $page    = 0
        $perPage = 200
        do {
            $batch = Invoke-MMRequest -Endpoint "teams/$TeamId/members?page=$page&per_page=$perPage"
            $batch | ConvertTo-MMTeamMember
            $page++
        } while ($batch.Count -eq $perPage)
    }
}
