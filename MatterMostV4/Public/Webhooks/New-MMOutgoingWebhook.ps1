# Creates a new outgoing webhook in MatterMost

function New-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Creates a new outgoing webhook for a MatterMost team.
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
