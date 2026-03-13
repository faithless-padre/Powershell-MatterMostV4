# Обновление канала MatterMost

function Set-MMChannel {
    <#
    .SYNOPSIS
        Обновляет параметры канала MatterMost.
    .EXAMPLE
        Set-MMChannel -ChannelId 'abc123' -DisplayName 'New Name'
    .EXAMPLE
        Get-MMChannel -ChannelId 'abc123' | Set-MMChannel -Header 'New header'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$ChannelId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$DisplayName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Purpose,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Header
    )

    process {
        $current = Invoke-MMRequest -Endpoint "channels/$ChannelId"

        $body = @{
            id           = $ChannelId
            display_name = if ($PSBoundParameters.ContainsKey('DisplayName')) { $DisplayName } else { $current.display_name }
            purpose      = if ($PSBoundParameters.ContainsKey('Purpose'))     { $Purpose }     else { $current.purpose }
            header       = if ($PSBoundParameters.ContainsKey('Header'))      { $Header }      else { $current.header }
        }

        Invoke-MMRequest -Endpoint "channels/$ChannelId" -Method PUT -Body $body
    }
}
