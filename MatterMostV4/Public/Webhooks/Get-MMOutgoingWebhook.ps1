# Retrieves outgoing webhooks from MatterMost

function Get-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Gets outgoing webhooks. Returns a single webhook by ID or a list filtered by team or channel.
    .DESCRIPTION
        Retrieves outgoing webhooks from MatterMost via GET /hooks/outgoing.
        Without parameters, returns all outgoing webhooks visible to the current user.
        Filter by team or channel ID. Use -HookId to fetch a specific webhook.
        Outgoing webhooks fire when a message matches configured trigger words, posting to callback URLs.
    .PARAMETER HookId
        The ID of a specific outgoing webhook to retrieve.
    .PARAMETER TeamId
        Filters webhooks to those belonging to the specified team ID.
    .PARAMETER TeamName
        Filters webhooks to those belonging to the named team. Resolved to an ID internally.
    .PARAMETER TeamIdFromPipe
        Team ID accepted from pipeline input (by property name: id or team_id).
    .PARAMETER ChannelId
        Further filters results to webhooks associated with the specified channel ID.
    .PARAMETER Page
        The page number for paginated list results (0-based). Default is 0.
    .PARAMETER PerPage
        The number of webhooks per page. Default is 60.
    .OUTPUTS
        MMOutgoingWebhook. One or more outgoing webhook objects.
    .EXAMPLE
        Get-MMOutgoingWebhook
    .EXAMPLE
        Get-MMOutgoingWebhook -HookId 'abc123'
    .EXAMPLE
        Get-MMOutgoingWebhook -TeamName 'my-team'
    .EXAMPLE
        Get-MMTeam -Name 'my-team' | Get-MMOutgoingWebhook
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('MMOutgoingWebhook')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$HookId,

        [Parameter(ParameterSetName = 'List')]
        [string]$TeamId,

        [Parameter(ParameterSetName = 'ByTeamName')]
        [string]$TeamName,

        [Parameter(ParameterSetName = 'ByTeamPipeline', ValueFromPipelineByPropertyName)]
        [Alias('id', 'team_id')]
        [string]$TeamIdFromPipe,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'ByTeamName')]
        [Parameter(ParameterSetName = 'ByTeamPipeline')]
        [string]$ChannelId,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'ByTeamName')]
        [Parameter(ParameterSetName = 'ByTeamPipeline')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'ByTeamName')]
        [Parameter(ParameterSetName = 'ByTeamPipeline')]
        [int]$PerPage = 60
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "hooks/outgoing/$HookId" -Method GET | ConvertTo-MMOutgoingWebhook
            return
        }

        $resolvedTeamId = switch ($PSCmdlet.ParameterSetName) {
            'ByTeamName'     { (Get-MMTeam -Name $TeamName).id }
            'ByTeamPipeline' { $TeamIdFromPipe }
            default          { $TeamId }
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($resolvedTeamId) { $query += "&team_id=$resolvedTeamId" }
        if ($ChannelId)      { $query += "&channel_id=$ChannelId" }

        Invoke-MMRequest -Endpoint "hooks/outgoing?$query" -Method GET |
            ForEach-Object { $_ | ConvertTo-MMOutgoingWebhook }
    }
}
