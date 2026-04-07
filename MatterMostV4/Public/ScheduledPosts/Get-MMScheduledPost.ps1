# Получение отложенных постов пользователя MatterMost

function Get-MMScheduledPost {
    <#
    .SYNOPSIS
        Returns scheduled posts for the current user in a team.
    .DESCRIPTION
        Retrieves all scheduled posts for the currently authenticated user in the specified team.
        Results are a flat list of MMScheduledPost objects across all channels.
        Requires MatterMost server 10.3+.
    .PARAMETER TeamId
        The ID of the team. If omitted, uses the default team set during Connect-MMServer.
    .PARAMETER IncludeDirectChannels
        If specified, includes scheduled posts from DMs and group messages.
    .OUTPUTS
        MMScheduledPost. One or more scheduled post objects.
    .EXAMPLE
        Get-MMScheduledPost
    .EXAMPLE
        Get-MMScheduledPost -TeamId 'abc123' -IncludeDirectChannels
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Get-MMScheduledPost
    #>
    [OutputType('MMScheduledPost')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter()]
        [switch]$IncludeDirectChannels
    )

    process {
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

        $query = if ($IncludeDirectChannels) { '?includeDirectChannels=true' } else { '' }

        $raw = Invoke-MMRequest -Endpoint "posts/scheduled/team/$resolvedTeamId$query"

        # API returns a map of channel_id -> []ScheduledPost — flatten it
        foreach ($prop in $raw.PSObject.Properties) {
            $prop.Value | ConvertTo-MMScheduledPost
        }
    }
}
