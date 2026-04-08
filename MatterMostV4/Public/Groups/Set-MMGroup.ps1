# Обновление (patch) группы MatterMost

function Set-MMGroup {
    <#
    .SYNOPSIS
        Обновляет свойства группы MatterMost (patch).
    .EXAMPLE
        Set-MMGroup -GroupId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMGroup -GroupId 'abc123' | Set-MMGroup -AllowReference $false
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$GroupId,

        [string]$Name,

        [string]$DisplayName,

        [System.Nullable[bool]]$AllowReference
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('Name'))           { $body['name']            = $Name }
        if ($PSBoundParameters.ContainsKey('DisplayName'))    { $body['display_name']    = $DisplayName }
        if ($PSBoundParameters.ContainsKey('AllowReference')) { $body['allow_reference'] = $AllowReference }

        Invoke-MMRequest -Endpoint "groups/$GroupId/patch" -Method PUT -Body $body
    }
}
