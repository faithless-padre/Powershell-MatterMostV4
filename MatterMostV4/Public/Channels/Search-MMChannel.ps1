# Поиск каналов MatterMost по строке

function Search-MMChannel {
    <#
    .SYNOPSIS
        Searches MatterMost channels by term within a team.
    .DESCRIPTION
        Sends POST /channels/search with the given term and team_id.
        Returns all channels whose name or display name matches the search term.
    .PARAMETER Term
        The search term to match against channel names and display names.
    .PARAMETER TeamId
        The team ID to scope the search. Defaults to the configured default team.
    .OUTPUTS
        MMChannel
    .EXAMPLE
        Search-MMChannel -Term 'dev'
    .EXAMPLE
        Search-MMChannel -Term 'town' -TeamId 'abc123'
    #>
    [OutputType('MMChannel')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Term,

        [string]$TeamId
    )

    process {
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }
        $body = @{
            term    = $Term
            team_id = $resolvedTeamId
        }
        $result = Invoke-MMRequest -Endpoint 'channels/search' -Method POST -Body $body
        $result | ConvertTo-MMChannel
    }
}
