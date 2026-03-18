# Updates an existing outgoing webhook in MatterMost

function Set-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Updates an existing MatterMost outgoing webhook.
    .DESCRIPTION
        Sends PUT /hooks/outgoing/{hook_id} to update the outgoing webhook configuration.
        Both -DisplayName and -CallbackUrls are required (full PUT, not PATCH).
        Pipe from Get-MMOutgoingWebhook to update specific fields while preserving others.
    .PARAMETER HookId
        The ID of the webhook to update. Accepts pipeline input by property name (id).
    .PARAMETER DisplayName
        The updated display name for the webhook.
    .PARAMETER CallbackUrls
        An updated array of URLs to call when the webhook triggers.
    .PARAMETER TriggerWords
        An updated array of trigger words that activate the webhook.
    .PARAMETER ChannelId
        An updated channel ID to restrict the webhook to a specific channel.
    .PARAMETER Description
        An updated description of the webhook's purpose.
    .OUTPUTS
        MMOutgoingWebhook. The updated webhook object.
    .EXAMPLE
        Set-MMOutgoingWebhook -HookId 'abc123' -DisplayName 'New Name' -CallbackUrls @('https://example.com/hook')
    .EXAMPLE
        Get-MMOutgoingWebhook -HookId 'abc123' | Set-MMOutgoingWebhook -DisplayName 'New Name' -CallbackUrls @('https://example.com/hook')
    #>
    [CmdletBinding()]
    [OutputType('MMOutgoingWebhook')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$HookId,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string[]]$CallbackUrls,

        [Parameter()]
        [string[]]$TriggerWords,

        [Parameter()]
        [string]$ChannelId,

        [Parameter()]
        [string]$Description
    )

    process {
        $body = @{
            id            = $HookId
            display_name  = $DisplayName
            callback_urls = $CallbackUrls
        }
        if ($TriggerWords) { $body['trigger_words'] = $TriggerWords }
        if ($ChannelId)    { $body['channel_id']    = $ChannelId }
        if ($Description)  { $body['description']   = $Description }

        Invoke-MMRequest -Endpoint "hooks/outgoing/$HookId" -Method PUT -Body $body | ConvertTo-MMOutgoingWebhook
    }
}
