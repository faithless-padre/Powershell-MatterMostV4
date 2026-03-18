# Retrieves incoming webhooks from MatterMost

function Get-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Gets incoming webhooks. Returns a single webhook by ID or a list filtered by team.
    .DESCRIPTION
        Retrieves incoming webhooks from MatterMost via GET /hooks/incoming.
        Without parameters, returns all incoming webhooks visible to the current user.
        Filter by team using -TeamId, -TeamName, or pipe a team object.
        Use -HookId to fetch a specific webhook by its ID.
    .PARAMETER HookId
        The ID of a specific incoming webhook to retrieve.
    .PARAMETER TeamId
        Filters webhooks to those belonging to the specified team ID.
    .PARAMETER TeamName
        Filters webhooks to those belonging to the named team. Resolved to an ID internally.
    .PARAMETER TeamIdFromPipe
        Team ID accepted from pipeline input (by property name: id or team_id).
    .PARAMETER Page
        The page number for paginated list results (0-based). Default is 0.
    .PARAMETER PerPage
        The number of webhooks per page. Default is 60.
    .OUTPUTS
        MMIncomingWebhook. One or more incoming webhook objects.
    .EXAMPLE
        Get-MMIncomingWebhook
    .EXAMPLE
        Get-MMIncomingWebhook -HookId 'abc123'
    .EXAMPLE
        Get-MMIncomingWebhook -TeamName 'my-team'
    .EXAMPLE
        Get-MMTeam -Name 'my-team' | Get-MMIncomingWebhook
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('MMIncomingWebhook')]
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
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'ByTeamName')]
        [Parameter(ParameterSetName = 'ByTeamPipeline')]
        [int]$PerPage = 60
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "hooks/incoming/$HookId" -Method GET | ConvertTo-MMIncomingWebhook
            return
        }

        $resolvedTeamId = switch ($PSCmdlet.ParameterSetName) {
            'ByTeamName'     { (Get-MMTeam -Name $TeamName).id }
            'ByTeamPipeline' { $TeamIdFromPipe }
            default          { $TeamId }
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($resolvedTeamId) { $query += "&team_id=$resolvedTeamId" }

        Invoke-MMRequest -Endpoint "hooks/incoming?$query" -Method GET |
            ForEach-Object { $_ | ConvertTo-MMIncomingWebhook }
    }
}
