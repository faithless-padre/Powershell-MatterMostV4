# Получение slash-команд MatterMost по команде или команды

function Get-MMCommand {
    <#
    .SYNOPSIS
        Returns MatterMost slash commands by team or by command ID.
    .DESCRIPTION
        Two parameter sets:
          - ByTeam: lists all custom commands for a team (GET /commands?team_id={team_id})
          - ById:   fetches a single command by its ID (GET /commands/{command_id})
    .PARAMETER TeamId
        The team ID to list commands for.
    .PARAMETER CommandId
        The ID of the specific command to fetch.
    .OUTPUTS
        PSCustomObject. One or more command objects.
    .EXAMPLE
        Get-MMCommand -TeamId 'abc123'
    .EXAMPLE
        Get-MMCommand -CommandId 'cmd456'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByTeam')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ByTeam')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$CommandId
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ByTeam' { Invoke-MMRequest -Endpoint "commands?team_id=$TeamId&custom_only=true" }
            'ById'   { Invoke-MMRequest -Endpoint "commands/$CommandId" }
        }
    }
}
