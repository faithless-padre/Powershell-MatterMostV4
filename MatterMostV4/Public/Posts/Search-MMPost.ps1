# Ищет посты в команде MatterMost по тексту

function Search-MMPost {
    <#
    .SYNOPSIS
        Searches for posts in a MatterMost team by text terms.
    .DESCRIPTION
        Calls POST /teams/{team_id}/posts/search to perform a full-text search.
        Returns matching posts as MMPost objects. Use -IsOrSearch to match any term
        instead of all terms. Use -IncludeDeletedChannels to include posts from archived channels.
    .PARAMETER Terms
        The search terms to look for. Multiple words are treated as AND by default.
    .PARAMETER TeamId
        The team ID to search within. Defaults to the session default team.
    .PARAMETER IsOrSearch
        When specified, matches posts containing ANY of the terms (OR logic) instead of ALL.
    .PARAMETER IncludeDeletedChannels
        When specified, includes posts from deleted/archived channels in results.
    .OUTPUTS
        MMPost. Zero or more matching post objects.
    .EXAMPLE
        Search-MMPost -Terms 'deployment failed'
    .EXAMPLE
        Search-MMPost -Terms 'foo bar' -IsOrSearch
    .EXAMPLE
        Search-MMPost -Terms 'incident' -TeamId 'abc123' -IncludeDeletedChannels
    #>
    [CmdletBinding()]
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory)]
        [string]$Terms,

        [Parameter()]
        [string]$TeamId,

        [Parameter()]
        [switch]$IsOrSearch,

        [Parameter()]
        [switch]$IncludeDeletedChannels
    )

    process {
        if (-not $TeamId) { $TeamId = Get-MMDefaultTeamId }

        $body = @{
            terms                    = $Terms
            is_or_search             = [bool]$IsOrSearch
            time_zone_offset         = 0
            include_deleted_channels = [bool]$IncludeDeletedChannels
            page                     = 0
            per_page                 = 60
        }

        $raw = Invoke-MMRequest -Endpoint "teams/$TeamId/posts/search" -Method POST -Body $body

        if ($raw.order -and $raw.posts) {
            foreach ($postId in $raw.order) {
                $raw.posts.$postId | ConvertTo-MMPost
            }
        }
    }
}
