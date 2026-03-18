# Retrieves bot accounts from MatterMost

function Get-MMBot {
    <#
    .SYNOPSIS
        Gets a MatterMost bot by ID, returns a list of bots, or filters bots by expression.
    .EXAMPLE
        Get-MMBot
    .EXAMPLE
        Get-MMBot -BotUserId 'abc123'
    .EXAMPLE
        Get-MMBot -IncludeDeleted
    .EXAMPLE
        Get-MMBot -OnlyOrphaned
    .EXAMPLE
        Get-MMBot -Filter { $_.username -like 'ci*' }
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$BotUserId,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'Filter')]
        [switch]$IncludeDeleted,

        [Parameter(ParameterSetName = 'List')]
        [Parameter(ParameterSetName = 'Filter')]
        [switch]$OnlyOrphaned,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'List')]
        [int]$PerPage = 60,

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [scriptblock]$Filter
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'ById') {
            Invoke-MMRequest -Endpoint "bots/$BotUserId" -Method GET | ConvertTo-MMBot
            return
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filter') {
            $page    = 0
            $perPage = 60
            $all     = @()
            do {
                $query = "page=$page&per_page=$perPage"
                if ($IncludeDeleted) { $query += '&include_deleted=true' }
                if ($OnlyOrphaned)   { $query += '&only_orphaned=true' }
                $batch = Invoke-MMRequest -Endpoint "bots?$query" -Method GET
                $all  += $batch
                $page++
            } while ($batch.Count -eq $perPage)
            $all | ConvertTo-MMBot | Where-Object $Filter
            return
        }

        $query = "page=$Page&per_page=$PerPage"
        if ($IncludeDeleted) { $query += '&include_deleted=true' }
        if ($OnlyOrphaned)   { $query += '&only_orphaned=true' }

        Invoke-MMRequest -Endpoint "bots?$query" -Method GET |
            ForEach-Object { $_ | ConvertTo-MMBot }
    }
}
