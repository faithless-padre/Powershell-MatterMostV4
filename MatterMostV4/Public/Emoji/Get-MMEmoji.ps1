# Retrieves custom emoji from MatterMost

function Get-MMEmoji {
    <#
    .SYNOPSIS
        Gets custom emoji by ID, name, list of names, or returns all custom emoji.
    .EXAMPLE
        Get-MMEmoji
    .EXAMPLE
        Get-MMEmoji -EmojiId 'abc123'
    .EXAMPLE
        Get-MMEmoji -Name 'pester'
    .EXAMPLE
        Get-MMEmoji -Names @('pester', 'party')
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
