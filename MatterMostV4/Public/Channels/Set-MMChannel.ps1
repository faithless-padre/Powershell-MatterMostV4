# Обновление канала MatterMost

function Set-MMChannel {
    <#
    .SYNOPSIS
        Updates MatterMost channel settings (PUT /channels/{id}/patch).
    .DESCRIPTION
        Sends a PATCH request to /channels/{channel_id}/patch. Only the parameters you provide are updated;
        all other channel properties remain unchanged. Use -Properties for API fields not covered by named parameters.
    .PARAMETER ChannelId
        The ID of the channel to update. Accepts pipeline input by property name (id).
    .PARAMETER Name
        New channel handle (URL slug).
    .PARAMETER DisplayName
        New display name for the channel.
    .PARAMETER Purpose
        New purpose text for the channel.
    .PARAMETER Header
        New header text for the channel (supports markdown).
    .PARAMETER GroupConstrained
        When true, membership is managed by group sync and cannot be changed manually.
    .PARAMETER AutoTranslation
        When true, messages in the channel are automatically translated.
    .PARAMETER BannerInfo
        A hashtable with banner configuration fields (message, background color, etc.).
    .PARAMETER Properties
        A hashtable of additional API fields not covered by named parameters.
    .OUTPUTS
        MMChannel. The updated channel object.
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Set-MMChannel -Header 'New header'
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -GroupConstrained $true
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -Properties @{ new_field = 'value' }
    #>
    [OutputType('MMChannel')]
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

        Invoke-MMRequest -Endpoint "channels/$ChannelId/patch" -Method PUT -Body $body | ConvertTo-MMChannel
    }
}
