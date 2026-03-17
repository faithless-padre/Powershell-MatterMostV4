# Creates a new incoming webhook in MatterMost

function New-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Creates a new incoming webhook for a MatterMost channel.
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
