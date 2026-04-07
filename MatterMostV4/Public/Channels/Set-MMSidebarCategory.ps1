# Обновление категории сайдбара MatterMost

function Set-MMSidebarCategory {
    <#
    .SYNOPSIS
        Updates an existing sidebar category.
    .DESCRIPTION
        Sends PUT /users/{user_id}/teams/{team_id}/channels/categories/{category_id}
        to update a sidebar category's display name and/or channel list.
        Only the parameters you explicitly pass will be included in the request body.
        Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER CategoryId
        The ID of the sidebar category to update. Accepts pipeline input by property name (id).
    .PARAMETER DisplayName
        New display name for the category.
    .PARAMETER ChannelIds
        New array of channel IDs for the category.
    .PARAMETER UserId
        The user ID. Defaults to the currently authenticated user.
    .PARAMETER TeamId
        The team ID. Defaults to the configured default team.
    .OUTPUTS
        MMSidebarCategory
    .EXAMPLE
        Set-MMSidebarCategory -CategoryId 'cat123' -DisplayName 'Updated Name'
    .EXAMPLE
        Get-MMSidebarCategory -CategoryId 'cat123' | Set-MMSidebarCategory -ChannelIds @('ch1','ch2')
    #>
    [OutputType('MMSidebarCategory')]
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$CategoryId,

        [string]$DisplayName,
        [string[]]$ChannelIds,
        [string]$UserId,
        [string]$TeamId
    )

    process {
        if ($PSCmdlet.ShouldProcess($CategoryId, 'Update sidebar category')) {
            $resolvedUserId = if ($UserId) { $UserId } else { (Invoke-MMRequest -Endpoint 'users/me').id }
            $resolvedTeamId = if ($TeamId) { $TeamId } else { Get-MMDefaultTeamId }

            $body = @{ id = $CategoryId; user_id = $resolvedUserId; team_id = $resolvedTeamId; type = 'custom' }
            if ($PSBoundParameters.ContainsKey('DisplayName')) { $body['display_name'] = $DisplayName }
            if ($PSBoundParameters.ContainsKey('ChannelIds'))  { $body['channel_ids']  = $ChannelIds  }

            Invoke-MMRequest -Endpoint "users/$resolvedUserId/teams/$resolvedTeamId/channels/categories/$CategoryId" -Method PUT -Body $body |
                ConvertTo-MMSidebarCategory
        }
    }
}
