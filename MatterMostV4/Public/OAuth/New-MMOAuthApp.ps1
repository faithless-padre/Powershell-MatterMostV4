# Создание нового OAuth-приложения в MatterMost

function New-MMOAuthApp {
    <#
    .SYNOPSIS
        Creates a new OAuth app in MatterMost.
    .EXAMPLE
        New-MMOAuthApp -Name 'MyApp' -Description 'My OAuth App' -CallbackUrls 'https://example.com/callback' -Homepage 'https://example.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Description,

        [Parameter(Mandatory)]
        [string[]]$CallbackUrls,

        [Parameter(Mandatory)]
        [string]$Homepage,

        [string]$IconUrl,

        [switch]$IsTrusted
    )

    process {
        $body = @{
            name          = $Name
            description   = $Description
            callback_urls = $CallbackUrls
            homepage      = $Homepage
            is_trusted    = $IsTrusted.IsPresent
        }

        if ($PSBoundParameters.ContainsKey('IconUrl')) {
            $body['icon_url'] = $IconUrl
        }

        Invoke-MMRequest -Endpoint 'oauth/apps' -Method POST -Body $body
    }
}
