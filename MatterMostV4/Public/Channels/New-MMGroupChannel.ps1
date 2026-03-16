# Создание группового канала (GM) для нескольких пользователей

function New-MMGroupChannel {
    <#
    .SYNOPSIS
        Creates a group message channel for 3–8 MatterMost users.
    .EXAMPLE
        New-MMGroupChannel -UserIds 'id1', 'id2', 'id3'
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory)]
        [ValidateCount(3, 8)]
        [string[]]$UserIds
    )

    Invoke-MMRequest -Endpoint 'channels/group' -Method POST -Body $UserIds |
        ConvertTo-MMChannel
}
