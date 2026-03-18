# Изменение приватности канала MatterMost (public ↔ private)

function Set-MMChannelPrivacy {
    <#
    .SYNOPSIS
        Updates MatterMost channel privacy: Public or Private.
    .DESCRIPTION
        Sends PUT /channels/{channel_id}/privacy to toggle a channel between public ('O') and private ('P').
        Requires channel admin or system admin privileges.
    .PARAMETER ChannelId
        The ID of the channel to update. Accepts pipeline input by property name (id).
    .PARAMETER Privacy
        The new privacy setting. 'Public' for open channels, 'Private' for invite-only channels.
    .OUTPUTS
        MMChannel. The updated channel object.
    .EXAMPLE
        Set-MMChannelPrivacy -ChannelId 'abc123' -Privacy Private
    .EXAMPLE
        Get-MMChannel -Name 'general' | Set-MMChannelPrivacy -Privacy Public
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [ValidateSet('Public', 'Private')]
        [string]$Privacy
    )

    process {
        $value = if ($Privacy -eq 'Public') { 'O' } else { 'P' }
        Invoke-MMRequest -Endpoint "channels/$ChannelId/privacy" -Method PUT -Body @{ privacy = $value } |
            ConvertTo-MMChannel
    }
}
