# Updates an existing outgoing webhook in MatterMost

function Set-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Updates an existing MatterMost outgoing webhook.
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
