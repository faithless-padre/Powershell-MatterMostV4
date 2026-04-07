# Удаление пользовательской категории сайдбара MatterMost

function Remove-MMSidebarCategory {
    <#
    .SYNOPSIS
        Deletes a custom sidebar category.
    .DESCRIPTION
        Sends DELETE /users/{user_id}/teams/{team_id}/channels/categories/{category_id}
        to remove a custom sidebar category. Only custom categories (type = 'custom')
        can be deleted. Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER CategoryId
        The ID of the sidebar category to delete. Accepts pipeline input by property name (id).
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        None
    .EXAMPLE
        Remove-MMSidebarCategory -CategoryId 'cat123'
    .EXAMPLE
        Get-MMSidebarCategories | Where-Object display_name -eq 'Old Category' | Remove-MMSidebarCategory
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CategoryId,

        [string]$UserId,
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($CategoryId, 'Delete sidebar category')) {
            $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
            $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

            Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories/$CategoryId" -Method DELETE
        }
    }
}
