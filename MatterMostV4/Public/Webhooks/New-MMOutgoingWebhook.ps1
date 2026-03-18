# Creates a new outgoing webhook in MatterMost

function New-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Creates a new outgoing webhook for a MatterMost team.
    .DESCRIPTION
        Sends POST /hooks/outgoing to create a new outgoing webhook.
        The webhook fires when a message in the team matches one of the configured trigger words,
        then POSTs the message data to all configured callback URLs.
        Supports team resolution by name or by piping a team object.
    .PARAMETER TeamId
        The ID of the team to scope the webhook to. Used with the ById parameter set.
    .PARAMETER TeamName
        The name of the team to scope the webhook to. Used with the ByName parameter set.
    .PARAMETER TeamIdFromPipe
        Team ID accepted from pipeline input (by property name: id or team_id).
    .PARAMETER DisplayName
        The display name for the webhook shown in the admin console.
    .PARAMETER TriggerWords
        An array of words that trigger the webhook when a message starts with them.
    .PARAMETER CallbackUrls
        An array of URLs to call when the webhook is triggered.
    .PARAMETER ChannelId
        Optionally restrict the webhook to a specific channel ID. If omitted, monitors all channels.
    .PARAMETER Description
        An optional description of the webhook's purpose.
    .PARAMETER TriggerWhen
        When to trigger: 0 = first word must match (default), 1 = any word must match.
    .PARAMETER ContentType
        The Content-Type for callback requests: 'application/json' or 'application/x-www-form-urlencoded'.
    .OUTPUTS
        MMOutgoingWebhook. The newly created webhook object.
    .EXAMPLE
        New-MMOutgoingWebhook -TeamId 'abc123' -DisplayName 'My Hook' -TriggerWords @('!cmd') -CallbackUrls @('https://example.com/hook')
    .EXAMPLE
        New-MMOutgoingWebhook -TeamName 'my-team' -DisplayName 'My Hook' -TriggerWords @('!cmd') -CallbackUrls @('https://example.com/hook')
    .EXAMPLE
        Get-MMTeam -Name 'my-team' | New-MMOutgoingWebhook -DisplayName 'My Hook' -TriggerWords @('!cmd') -CallbackUrls @('https://example.com/hook')
    #>
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType('MMOutgoingWebhook')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$TeamId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$TeamName,

        [Parameter(Mandatory, ParameterSetName = 'ByPipeline', ValueFromPipelineByPropertyName)]
        [Alias('id', 'team_id')]
        [string]$TeamIdFromPipe,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [Parameter(Mandatory)]
        [string[]]$TriggerWords,

        [Parameter(Mandatory)]
        [string[]]$CallbackUrls,

        [Parameter()]
        [string]$ChannelId,

        [Parameter()]
        [string]$Description,

        [Parameter()]
        [ValidateSet(0, 1)]
        [int]$TriggerWhen = 0,

        [Parameter()]
        [ValidateSet('application/json', 'application/x-www-form-urlencoded')]
        [string]$ContentType = 'application/x-www-form-urlencoded'
    )

    process {
        $resolvedTeamId = switch ($PSCmdlet.ParameterSetName) {
            'ByName'     { (Get-MMTeam -Name $TeamName).id }
            'ByPipeline' { $TeamIdFromPipe }
            default      { $TeamId }
        }

        $body = @{
            team_id       = $resolvedTeamId
            display_name  = $DisplayName
            trigger_words = $TriggerWords
            callback_urls = $CallbackUrls
            trigger_when  = $TriggerWhen
            content_type  = $ContentType
        }
        if ($ChannelId)   { $body['channel_id']  = $ChannelId }
        if ($Description) { $body['description'] = $Description }

        Invoke-MMRequest -Endpoint 'hooks/outgoing' -Method POST -Body $body | ConvertTo-MMOutgoingWebhook
    }
}
