# Searches custom emoji in MatterMost

function Find-MMEmoji {
    <#
    .SYNOPSIS
        Searches MatterMost custom emoji by name term or returns autocomplete suggestions.
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
