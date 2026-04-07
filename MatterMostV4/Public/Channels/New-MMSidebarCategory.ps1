# Создание новой категории сайдбара MatterMost

function New-MMSidebarCategory {
    <#
    .SYNOPSIS
        Creates a new custom sidebar category for a user in a team.
    .DESCRIPTION
        Sends POST /users/{user_id}/teams/{team_id}/channels/categories to create
        a new custom sidebar category. Optionally pre-populates it with channel IDs.
    .PARAMETER DisplayName
        The display name for the new category.
    .PARAMETER ChannelIds
        Optional array of channel IDs to include in the category.
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        MMSidebarCategory
    .EXAMPLE
        New-MMSidebarCategory -DisplayName 'My Projects'
    .EXAMPLE
        New-MMSidebarCategory -DisplayName 'Dev Channels' -ChannelIds @('ch1', 'ch2')
    #>
    [OutputType('MMSidebarCategory')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName,

        [string[]]$ChannelIds,
        [string]$UserId,
        [string]$TeamId
    )

    process {
        $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

        $channelIdsValue = if ($PSBoundParameters.ContainsKey('ChannelIds')) { $ChannelIds } else { [string[]]@() }
        $body = @{
            display_name = $DisplayName
            type         = 'custom'
            channel_ids  = $channelIdsValue
            user_id      = $resolvedUserId
            team_id      = $resolvedTeamId
        }

        Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories" -Method POST -Body $body |
            ConvertTo-MMSidebarCategory
    }
}
