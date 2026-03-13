# Получение команды (team) MatterMost

function Get-MMTeam {
    <#
    .SYNOPSIS
        Возвращает команду MatterMost по ID, имени или список всех команд.
    .EXAMPLE
        Get-MMTeam -All
    .EXAMPLE
        Get-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'testteam'
    #>
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
            'ById'   { Invoke-MMRequest -Endpoint "teams/$TeamId" }
            'ByName' { Invoke-MMRequest -Endpoint "teams/name/$Name" }
            'All'    { Get-MMTeamList }
        }
    }
}
