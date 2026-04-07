# Получение пользователей MatterMost по группе групповых каналов

function Get-MMUsersByGroupChannel {
    <#
    .SYNOPSIS
        Returns users for one or more group (GM) channels as a hashtable keyed by channel ID.
    .DESCRIPTION
        Calls POST /users/group_channels with an array of channel IDs.
        Returns a hashtable where each key is a channel ID and each value is an array of MMUser objects
        who are members of that channel.
    .PARAMETER GroupChannelIds
        One or more group channel IDs to look up.
    .OUTPUTS
        System.Collections.Hashtable. Keys are channel IDs, values are MMUser arrays.
    .EXAMPLE
        Get-MMUsersByGroupChannel -GroupChannelIds 'chan1', 'chan2'
    .EXAMPLE
        $result = Get-MMUsersByGroupChannel -GroupChannelIds $gmChannel.id
        $result[$gmChannel.id]
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$GroupChannelIds
    )

    process {
        $raw = Invoke-MMRequest -Endpoint 'users/group_channels' -Method POST -Body $GroupChannelIds
        $result = @{}
        foreach ($prop in $raw.PSObject.Properties) {
            $result[$prop.Name] = $prop.Value | ConvertTo-MMUser
        }
        $result
    }
}
