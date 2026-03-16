# Получение команды (team) MatterMost

function Get-MMTeam {
    <#
    .SYNOPSIS
        Returns a MatterMost team by ID, name, or all teams.
    .EXAMPLE
        Get-MMTeam -All
    .EXAMPLE
        Get-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'testteam'
    #>
    [OutputType('MMTeam')]
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName', Position = 0)]
        [string]$Name
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById'   { Invoke-MMRequest -Endpoint "teams/$TeamId" | ConvertTo-MMTeam }
            'ByName' { Invoke-MMRequest -Endpoint "teams/name/$Name" | ConvertTo-MMTeam }
            'All'    { Get-MMTeamList | ConvertTo-MMTeam }
        }
    }
}
