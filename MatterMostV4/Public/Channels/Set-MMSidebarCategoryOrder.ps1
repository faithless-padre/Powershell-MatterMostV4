# Установка порядка категорий сайдбара MatterMost

function Set-MMSidebarCategoryOrder {
    <#
    .SYNOPSIS
        Sets the display order of sidebar categories for a user in a team.
    .DESCRIPTION
        Sends PUT /users/{user_id}/teams/{team_id}/channels/categories/order with
        the full ordered array of category IDs. Returns the updated order.
        Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER CategoryIds
        The full ordered array of sidebar category IDs.
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        System.String[]
    .EXAMPLE
        $order = Get-MMSidebarCategoryOrder
        Set-MMSidebarCategoryOrder -CategoryIds $order
    #>
    [OutputType([string[]])]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string[]]$CategoryIds,

        [string]$UserId,
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess('sidebar category order', 'Update')) {
            $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
            $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

            Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories/order" -Method PUT -Body $CategoryIds
        }
    }
}
