# Выполнение slash-команды MatterMost через API

function Invoke-MMCommand {
    <#
    .SYNOPSIS
        Executes a MatterMost slash command via the API (POST /commands/execute).
    .DESCRIPTION
        Sends a slash command string to the MatterMost execute endpoint.
        The command string should include the leading '/' and any arguments.
    .PARAMETER Command
        The full slash command string to execute, including the '/' prefix (e.g. '/hello world').
    .PARAMETER ChannelId
        The channel ID in which to execute the command.
    .PARAMETER TeamId
        The team ID in which to execute the command.
    .OUTPUTS
        PSCustomObject. The command response object.
    .EXAMPLE
        Invoke-MMCommand -Command '/hello world'
    .EXAMPLE
        Invoke-MMCommand -Command '/greet' -ChannelId 'ch123' -TeamId 'team456'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,

        [string]$ChannelId,
        [string]$TeamId
    )

    process {
        $body = @{ command = $Command }

        if ($PSBoundParameters.ContainsKey('ChannelId')) { $body['channel_id'] = $ChannelId }
        if ($PSBoundParameters.ContainsKey('TeamId'))    { $body['team_id']    = $TeamId }

        Invoke-MMRequest -Endpoint 'commands/execute' -Method POST -Body $body
    }
}
