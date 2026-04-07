# Получение порядка категорий сайдбара MatterMost

function Get-MMSidebarCategoryOrder {
    <#
    .SYNOPSIS
        Returns the ordered list of sidebar category IDs for a user in a team.
    .DESCRIPTION
        Sends GET /users/{user_id}/teams/{team_id}/channels/categories/order
        and returns the array of category IDs in display order.
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        System.String[]
    .EXAMPLE
        Get-MMSidebarCategoryOrder
    .EXAMPLE
        Get-MMSidebarCategoryOrder -UserId 'user123' -TeamId 'team456'
    #>
    [OutputType([string[]])]
    [CmdletBinding()]
    param(
        [string]$UserId,
        [string]$TeamId
    )

    process {
        $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

        Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories/order"
    }
}
