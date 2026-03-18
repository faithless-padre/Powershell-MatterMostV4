# Добавление пользователя в канал MatterMost

function Add-MMUserToChannel {
    <#
    .SYNOPSIS
        Adds a user to a MatterMost channel.
    .DESCRIPTION
        Posts a membership entry to /channels/{channel_id}/members. The user must already be a member
        of the team that owns the channel. Requires channel admin or system admin privileges.
    .PARAMETER ChannelId
        The ID of the channel to add the user to.
    .PARAMETER UserId
        The ID of the user to add. Accepts pipeline input by property name (id).
    .OUTPUTS
        System.Void.
    .EXAMPLE
        Add-MMUserToChannel -ChannelId 'chan123' -UserId 'user456'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Add-MMUserToChannel -ChannelId 'chan123'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ChannelId,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "channels/$ChannelId/members" -Method POST -Body @{ user_id = $UserId }
    }
}
