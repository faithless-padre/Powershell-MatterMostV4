# Получение категорий сайдбара пользователя MatterMost

function Get-MMSidebarCategories {
    <#
    .SYNOPSIS
        Returns sidebar categories for a user in a team.
    .DESCRIPTION
        Sends GET /users/{user_id}/teams/{team_id}/channels/categories and returns
        all sidebar categories as MMSidebarCategory objects.
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        MMSidebarCategory
    .EXAMPLE
        Get-MMSidebarCategories
    .EXAMPLE
        Get-MMSidebarCategories -UserId 'user123' -TeamId 'team456'
    #>
    [OutputType('MMSidebarCategory')]
    [CmdletBinding()]
    param(
        [string]$UserId,
        [string]$TeamId
    )

    process {
        $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
        $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

        $raw = Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories"
        foreach ($category in $raw.categories) {
            $category | ConvertTo-MMSidebarCategory
        }
    }
}
