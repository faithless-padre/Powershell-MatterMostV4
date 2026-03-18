# Searches custom emoji in MatterMost

function Find-MMEmoji {
    <#
    .SYNOPSIS
        Searches MatterMost custom emoji by name term or returns autocomplete suggestions.
    .DESCRIPTION
        Supports two modes: full search via POST /emoji/search (with optional prefix-only restriction),
        and autocomplete via GET /emoji/autocomplete for use in type-ahead scenarios.
    .PARAMETER Term
        The search term to look for in emoji names. Used with the Search parameter set.
    .PARAMETER PrefixOnly
        When specified, only emoji whose names start with Term are returned. Used with the Search parameter set.
    .PARAMETER Autocomplete
        A short prefix string to get autocomplete suggestions from /emoji/autocomplete. Used with the Autocomplete parameter set.
    .OUTPUTS
        MMEmoji. One or more matching emoji objects.
    .EXAMPLE
        Find-MMEmoji -Term 'party'
    .EXAMPLE
        Find-MMEmoji -Term 'par' -PrefixOnly
    .EXAMPLE
        Find-MMEmoji -Autocomplete 'par'
    #>
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    [OutputType('MMEmoji')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Search')]
        [string]$Term,

        [Parameter(ParameterSetName = 'Search')]
        [switch]$PrefixOnly,

        [Parameter(Mandatory, ParameterSetName = 'Autocomplete')]
        [string]$Autocomplete
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Autocomplete') {
            Invoke-MMRequest -Endpoint "emoji/autocomplete?name=$Autocomplete" -Method GET |
                ForEach-Object { $_ | ConvertTo-MMEmoji }
        } else {
            $body = @{ term = $Term }
            if ($PrefixOnly) { $body['prefix_only'] = $true }
            Invoke-MMRequest -Endpoint 'emoji/search' -Method POST -Body $body |
                ForEach-Object { $_ | ConvertTo-MMEmoji }
        }
    }
}
