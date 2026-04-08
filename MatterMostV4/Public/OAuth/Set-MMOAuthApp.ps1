# Обновление OAuth-приложения MatterMost

function Set-MMOAuthApp {
    <#
    .SYNOPSIS
        Updates an existing OAuth app in MatterMost.
    .EXAMPLE
        Set-MMOAuthApp -AppId 'abc123' -Name 'Updated Name'
    .EXAMPLE
        Get-MMOAuthApp -AppId 'abc123' | Set-MMOAuthApp -IsTrusted $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$AppId,

        [string]$Name,

        [string]$Description,

        [string[]]$CallbackUrls,

        [string]$Homepage,

        [string]$IconUrl,

        [System.Nullable[bool]]$IsTrusted
    )

    process {
        # MM API PUT требует полный объект — подтягиваем текущее состояние и мержим изменения
        $current = Invoke-MMRequest -Endpoint "oauth/apps/$AppId" -Method GET

        $body = @{
            id            = $AppId
            name          = $current.name
            description   = $current.description
            callback_urls = $current.callback_urls
            homepage      = $current.homepage
            is_trusted    = $current.is_trusted
        }
        if ($current.icon_url) { $body['icon_url'] = $current.icon_url }

        if ($PSBoundParameters.ContainsKey('Name'))         { $body['name']          = $Name }
        if ($PSBoundParameters.ContainsKey('Description'))  { $body['description']   = $Description }
        if ($PSBoundParameters.ContainsKey('CallbackUrls')) { $body['callback_urls'] = $CallbackUrls }
        if ($PSBoundParameters.ContainsKey('Homepage'))     { $body['homepage']      = $Homepage }
        if ($PSBoundParameters.ContainsKey('IconUrl'))      { $body['icon_url']      = $IconUrl }
        if ($PSBoundParameters.ContainsKey('IsTrusted'))    { $body['is_trusted']    = $IsTrusted }

        Invoke-MMRequest -Endpoint "oauth/apps/$AppId" -Method PUT -Body $body
    }
}
