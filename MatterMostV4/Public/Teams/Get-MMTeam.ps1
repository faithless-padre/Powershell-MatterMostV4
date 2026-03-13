# Получение команды (team) MatterMost

function Get-MMTeam {
    <#
    .SYNOPSIS
        Возвращает команду MatterMost по ID, имени или список всех команд.
    .EXAMPLE
        Get-MMTeam
    .EXAMPLE
        Get-MMTeam -TeamId 'abc123'
    .EXAMPLE
        Get-MMTeam -Name 'testteam'
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
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
