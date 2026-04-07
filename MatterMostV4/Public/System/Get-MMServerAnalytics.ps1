# Retrieves server analytics data from MatterMost

function Get-MMServerAnalytics {
    <#
    .SYNOPSIS
        Gets server analytics data from MatterMost.
    .DESCRIPTION
        Sends a POST request to /analytics/old with a name parameter that determines
        which analytics dataset to retrieve. Optionally scoped to a specific team.
        Requires manage_system permission.
    .PARAMETER Name
        The analytics dataset to retrieve. Default: 'standard'.
        Valid values: standard, post_counts_day, user_counts_with_posts_day, p99,
        r50, r95, system_counts, bot_posts_day.
    .PARAMETER TeamId
        Optional team ID to scope analytics to a specific team.
    .OUTPUTS
        PSCustomObject[]. Array of analytics row objects.
    .EXAMPLE
        Get-MMServerAnalytics
    .EXAMPLE
        Get-MMServerAnalytics -Name 'post_counts_day' -TeamId 'abc123'
    #>
    [OutputType('PSCustomObject')]
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('standard', 'post_counts_day', 'user_counts_with_posts_day', 'p99', 'r50', 'r95', 'system_counts', 'bot_posts_day')]
        [string]$Name = 'standard',

        [Parameter()]
        [string]$TeamId
    )

    process {
        $body = @{ name = $Name }
        if ($TeamId) { $body['team_id'] = $TeamId }

        Invoke-MMRequest -Endpoint 'analytics/old' -Method POST -Body $body
    }
}
