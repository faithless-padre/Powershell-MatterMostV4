# Retrieves custom emoji from MatterMost

function Get-MMEmoji {
    <#
    .SYNOPSIS
        Gets custom emoji by ID, name, list of names, or returns all custom emoji.
    .DESCRIPTION
        Retrieves MatterMost custom emoji objects. The default list mode supports pagination and optional
        sorting by name. Batch lookup by names uses POST /emoji/names. Use Find-MMEmoji for text search.
    .PARAMETER EmojiId
        The ID of the emoji to retrieve. Used with the ById parameter set.
    .PARAMETER Name
        The exact name of the emoji. Used with the ByName parameter set.
    .PARAMETER Names
        An array of emoji names for batch lookup. Used with the ByNames parameter set.
    .PARAMETER Page
        The page number for paginated list results (0-based). Used with the List parameter set.
    .PARAMETER PerPage
        The number of emoji per page. Default is 60. Used with the List parameter set.
    .PARAMETER Sort
        Sort order for list results. Use 'name' to sort alphabetically. Default is unsorted.
    .OUTPUTS
        MMEmoji. One or more emoji objects.
    .EXAMPLE
        Get-MMEmoji
    .EXAMPLE
        Get-MMEmoji -EmojiId 'abc123'
    .EXAMPLE
        Get-MMEmoji -Name 'pester'
    .EXAMPLE
        Get-MMEmoji -Names @('pester', 'party')
    .EXAMPLE
        Get-MMEmoji -Sort name
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [OutputType('MMEmoji')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById')]
        [string]$EmojiId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Name,

        [Parameter(Mandatory, ParameterSetName = 'ByNames')]
        [string[]]$Names,

        [Parameter(ParameterSetName = 'List')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'List')]
        [int]$PerPage = 60,

        [Parameter(ParameterSetName = 'List')]
        [ValidateSet('', 'name')]
        [string]$Sort = ''
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                Invoke-MMRequest -Endpoint "emoji/$EmojiId" -Method GET | ConvertTo-MMEmoji
            }
            'ByName' {
                Invoke-MMRequest -Endpoint "emoji/name/$Name" -Method GET | ConvertTo-MMEmoji
            }
            'ByNames' {
                Invoke-MMRequest -Endpoint 'emoji/names' -Method POST -Body $Names |
                    ForEach-Object { $_ | ConvertTo-MMEmoji }
            }
            'List' {
                $query = "page=$Page&per_page=$PerPage"
                if ($Sort) { $query += "&sort=$Sort" }
                Invoke-MMRequest -Endpoint "emoji?$query" -Method GET |
                    ForEach-Object { $_ | ConvertTo-MMEmoji }
            }
        }
    }
}
