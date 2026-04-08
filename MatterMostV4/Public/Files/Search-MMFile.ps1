# Поиск файлов в команде MatterMost

function Search-MMFile {
    <#
    .SYNOPSIS
        Searches for files in a MatterMost team by search terms.
    .PARAMETER Terms
        The search terms to use.
    .PARAMETER TeamId
        The team to search in. Defaults to the session default team.
    .PARAMETER IsOrSearch
        If specified, treats the search terms as OR-joined rather than AND-joined.
    .PARAMETER IncludeDeletedChannels
        If specified, includes files from deleted channels in results.
    .PARAMETER Page
        Page number for pagination. Defaults to 0.
    .PARAMETER PerPage
        Number of results per page. Defaults to 60.
    .EXAMPLE
        Search-MMFile -Terms 'report'
    .EXAMPLE
        Search-MMFile -Terms 'design mockup' -IsOrSearch -TeamId 'abc123'
    #>
    [OutputType('MMFile')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]$Terms,

        [Parameter()]
        [string]$TeamId,

        [Parameter()]
        [switch]$IsOrSearch,

        [Parameter()]
        [switch]$IncludeDeletedChannels,

        [Parameter()]
        [int]$Page = 0,

        [Parameter()]
        [int]$PerPage = 60
    )

    process {
        if (-not $TeamId) {
            $TeamId = Get-MMDefaultTeamId
        }

        $isOr     = if ($IsOrSearch) { 'true' } else { 'false' }
        $deleted  = if ($IncludeDeletedChannels) { 'true' } else { 'false' }
        $endpoint = "teams/$TeamId/files/search?terms=$([Uri]::EscapeDataString($Terms))&is_or_search=$isOr&include_deleted_channels=$deleted&page=$Page&per_page=$PerPage"

        $result = Invoke-MMRequest -Endpoint $endpoint

        if ($result -and $result.files) {
            $result.files.PSObject.Properties.Value | ConvertTo-MMFile
        }
        elseif ($result -and $result -is [System.Collections.IEnumerable] -and $result -isnot [string]) {
            $result | ConvertTo-MMFile
        }
    }
}
