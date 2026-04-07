# Изменение ролей участника канала MatterMost

function Set-MMChannelMemberRoles {
    <#
    .SYNOPSIS
        Sets the roles of a user in a MatterMost channel.
    .DESCRIPTION
        Sends PUT /channels/{channel_id}/members/{user_id}/roles to update the roles
        of a channel member. Roles are provided as a space-separated string.
        Supports -WhatIf / -Confirm via ShouldProcess.
    .PARAMETER ChannelId
        The ID of the channel.
    .PARAMETER UserId
        The ID of the user whose roles to update. Accepts pipeline input by property name (id).
    .PARAMETER Roles
        Space-separated role names, e.g. 'channel_user channel_admin'.
    .OUTPUTS
        None
    .EXAMPLE
        Set-MMChannelMemberRoles -ChannelId 'abc123' -UserId 'user456' -Roles 'channel_user channel_admin'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$Roles
    )

    process {
        if ($PSCmdlet.ShouldProcess("$UserId in $ChannelId", "Set channel member roles to '$Roles'")) {
            $body = @{ roles = $Roles }
            Invoke-MMRequest -Endpoint "channels/$ChannelId/members/$UserId/roles" -Method PUT -Body $body | Out-Null
        }
    }
}
