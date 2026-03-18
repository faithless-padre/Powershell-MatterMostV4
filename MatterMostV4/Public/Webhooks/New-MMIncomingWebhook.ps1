# Creates a new incoming webhook in MatterMost

function New-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Creates a new incoming webhook for a MatterMost channel.
    .DESCRIPTION
        Sends POST /hooks/incoming to create a new incoming webhook that posts to the specified channel.
        The response includes the webhook URL which can be used to POST messages to the channel.
        Supports channel resolution by name or by piping a channel object.
    .PARAMETER ChannelId
        The ID of the channel the webhook will post to. Used with the ById parameter set.
    .PARAMETER ChannelName
        The name of the channel to post to. Used with the ByName parameter set.
    .PARAMETER ChannelIdFromPipe
        Channel ID accepted from pipeline input (by property name: id or channel_id).
    .PARAMETER DisplayName
        The display name for the webhook shown in the admin console.
    .PARAMETER Description
        An optional description of the webhook's purpose.
    .PARAMETER Username
        An optional override for the username displayed when the webhook posts a message.
    .PARAMETER IconUrl
        An optional URL of an icon image to use instead of the default bot icon.
    .PARAMETER ChannelLocked
        When true, the webhook can only post to its configured channel and ignores the channel in the payload.
    .OUTPUTS
        MMIncomingWebhook. The newly created webhook object including its ID.
    .EXAMPLE
        New-MMIncomingWebhook -ChannelId 'abc123' -DisplayName 'My Webhook'
    .EXAMPLE
        New-MMIncomingWebhook -ChannelName 'general' -DisplayName 'My Webhook' -Username 'bot'
    .EXAMPLE
        Get-MMChannel -Name 'general' | New-MMIncomingWebhook -DisplayName 'My Webhook'
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMIncomingWebhook')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$ChannelId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$ChannelName,

        [Parameter(Mandatory, ParameterSetName = 'ByPipeline', ValueFromPipelineByPropertyName)]
        [Alias('id', 'channel_id')]
        [string]$ChannelIdFromPipe,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [string]$Username,

        [Parameter()]
        [string]$IconUrl,

        [Parameter()]
        [bool]$ChannelLocked = $false
    )

    process {
        $resolvedChannelId = switch ($PSCmdlet.ParameterSetName) {
            'ByName'     { (Get-MMChannel -Name $ChannelName).id }
            'ByPipeline' { $ChannelIdFromPipe }
            default      { $ChannelId }
        }

        $body = @{
            channel_id   = $resolvedChannelId
            display_name = $DisplayName
        }
        if ($Description)    { $body['description']    = $Description }
        if ($Username)        { $body['username']       = $Username }
        if ($IconUrl)         { $body['icon_url']       = $IconUrl }
        if ($ChannelLocked)   { $body['channel_locked'] = $ChannelLocked }

        Invoke-MMRequest -Endpoint 'hooks/incoming' -Method POST -Body $body | ConvertTo-MMIncomingWebhook
    }
}
