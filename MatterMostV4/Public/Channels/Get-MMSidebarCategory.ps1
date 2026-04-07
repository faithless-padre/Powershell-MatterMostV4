# Получение конкретной категории сайдбара MatterMost

function Get-MMSidebarCategory {
    <#
    .SYNOPSIS
        Returns a single sidebar category by ID.
    .DESCRIPTION
        Sends GET /users/{user_id}/teams/{team_id}/channels/categories/{category_id}
        and returns the category as an MMSidebarCategory object.
    .PARAMETER CategoryId
        The ID of the sidebar category. Accepts pipeline input by property name (id).
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        MMSidebarCategory
    .EXAMPLE
        Get-MMSidebarCategory -CategoryId 'cat123'
    .EXAMPLE
        Get-MMSidebarCategories | Where-Object type -eq 'custom' | Get-MMSidebarCategory
    #>
    [OutputType('MMSidebarCategory')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CategoryId,

        [string]$UserId,
        [string]$TeamId
    )

    process {
        $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

        Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories/$CategoryId" |
            ConvertTo-MMSidebarCategory
    }
}
