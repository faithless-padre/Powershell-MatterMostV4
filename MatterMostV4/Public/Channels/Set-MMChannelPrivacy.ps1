# Изменение приватности канала MatterMost (public ↔ private)

function Set-MMChannelPrivacy {
    <#
    .SYNOPSIS
        Изменяет приватность канала MatterMost: Public (открытый) или Private (закрытый).
    .EXAMPLE
        Set-MMChannelPrivacy -ChannelId 'abc123' -Privacy Private
    .EXAMPLE
        Get-MMChannel -Name 'general' | Set-MMChannelPrivacy -Privacy Public
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(Mandatory)]
        [ValidateSet('Public', 'Private')]
        [string]$Privacy
    )

    process {
        $value = if ($Privacy -eq 'Public') { 'O' } else { 'P' }
        Invoke-MMRequest -Endpoint "channels/$ChannelId/privacy" -Method PUT -Body @{ privacy = $value } |
            ConvertTo-MMChannel
    }
}
