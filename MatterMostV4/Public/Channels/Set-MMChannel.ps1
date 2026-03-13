# Обновление канала MatterMost

function Set-MMChannel {
    <#
    .SYNOPSIS
        Обновляет параметры канала MatterMost (PUT /channels/{id}/patch).
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Set-MMChannel -Header 'New header'
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -GroupConstrained $true
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -Properties @{ new_field = 'value' }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [string]$Name,
        [string]$DisplayName,
        [string]$Purpose,
        [string]$Header,
        [nullable[bool]]$GroupConstrained,
        [nullable[bool]]$AutoTranslation,
        [hashtable]$BannerInfo,

        # Произвольные поля — для новых или незадокументированных свойств API
        [hashtable]$Properties
    )

    process {
        $paramMap = @{
            Name             = 'name'
            DisplayName      = 'display_name'
            Purpose          = 'purpose'
            Header           = 'header'
            GroupConstrained = 'group_constrained'
            AutoTranslation  = 'autotranslation'
            BannerInfo       = 'banner_info'
        }

        $body = @{}
        foreach ($param in $paramMap.Keys) {
            if ($PSBoundParameters.ContainsKey($param)) {
                $body[$paramMap[$param]] = $PSBoundParameters[$param]
            }
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) { $body[$key] = $Properties[$key] }
        }

        Invoke-MMRequest -Endpoint "channels/$ChannelId/patch" -Method PUT -Body $body
    }
}
