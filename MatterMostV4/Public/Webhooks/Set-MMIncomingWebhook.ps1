# Updates an existing incoming webhook in MatterMost

function Set-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Updates an existing MatterMost incoming webhook.
    .DESCRIPTION
        Sends PUT /hooks/incoming/{hook_id} to update the webhook configuration.
        Both -DisplayName and -ChannelId are required (full PUT, not PATCH).
        Use Get-MMIncomingWebhook to pipe an existing webhook and supply only the changed parameters.
    .PARAMETER HookId
        The ID of the webhook to update. Accepts pipeline input by property name (id).
    .PARAMETER DisplayName
        The updated display name for the webhook.
    .PARAMETER ChannelId
        The updated target channel ID. Accepts pipeline input by property name (channel_id).
    .PARAMETER Description
        An updated description of the webhook's purpose.
    .PARAMETER Username
        An override for the username displayed when posting messages.
    .PARAMETER IconUrl
        A URL of an icon image to display instead of the default bot icon.
    .PARAMETER ChannelLocked
        When true, the webhook ignores the channel field in payloads and always posts to the configured channel.
    .OUTPUTS
        MMIncomingWebhook. The updated webhook object.
    .EXAMPLE
        Set-MMIncomingWebhook -HookId 'abc123' -DisplayName 'New Name' -ChannelId 'ch456'
    .EXAMPLE
        Get-MMIncomingWebhook -HookId 'abc123' | Set-MMIncomingWebhook -DisplayName 'New Name'
    #>
    [CmdletBinding()]
    [OutputType('MMIncomingWebhook')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$HookId,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('channel_id')]
        [string]$ChannelId,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$Username,

        [Parameter()]
        [string]$IconUrl,

        [Parameter()]
        [bool]$ChannelLocked
    )

    process {
        $body = @{
            id           = $HookId
            display_name = $DisplayName
            channel_id   = $ChannelId
            description  = if ($Description) { $Description } else { '' }
        }
        if ($Username)     { $body['username']        = $Username }
        if ($IconUrl)      { $body['icon_url']        = $IconUrl }
        if ($PSBoundParameters.ContainsKey('ChannelLocked')) {
            $body['channel_locked'] = $ChannelLocked
        }

        Invoke-MMRequest -Endpoint "hooks/incoming/$HookId" -Method PUT -Body $body | ConvertTo-MMIncomingWebhook
    }
}
