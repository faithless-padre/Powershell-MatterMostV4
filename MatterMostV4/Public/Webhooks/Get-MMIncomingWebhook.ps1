# Retrieves incoming webhooks from MatterMost

function Get-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Gets incoming webhooks. Returns a single webhook by ID or a list filtered by team.
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
