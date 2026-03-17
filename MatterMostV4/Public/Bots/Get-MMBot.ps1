# Retrieves bot accounts from MatterMost

function Get-MMBot {
    <#
    .SYNOPSIS
        Gets a MatterMost bot by ID, or returns a list of bots.
    .EXAMPLE
        Get-MMBot
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123'
    .EXAMPLE
        Get-MMBot -IncludeDeleted
    .EXAMPLE
        Get-MMBot -OnlyOrphaned
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$BotUserId,

        [Parameter(ParameterSetName = 'List')]
        [switch]$IncludeDeleted,

        [Parameter(ParameterSetName = 'List')]
        [switch]$OnlyOrphaned,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'List')]
        [int]$PerPage = 60
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "bots/$BotUserId" -Method GET | ConvertTo-MMBot
            return
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($IncludeDeleted) { $query += '&include_deleted=true' }
        if ($OnlyOrphaned)   { $query += '&only_orphaned=true' }

        Invoke-MMRequest -Endpoint "bots?$query" -Method GET |
            ForEach-Object { $_ | ConvertTo-MMBot }
    }
}
