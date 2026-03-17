# Retrieves outgoing webhooks from MatterMost

function Get-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Gets outgoing webhooks. Returns a single webhook by ID or a list filtered by team or channel.
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
