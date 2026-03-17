# Updates an existing incoming webhook in MatterMost

function Set-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Updates an existing MatterMost incoming webhook.
    .EXAMPLE
        Set-MMIncomingWebhook -HookId 'abc123' -DisplayName 'New Name'
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

        [Parameter(Mandatory)]
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
