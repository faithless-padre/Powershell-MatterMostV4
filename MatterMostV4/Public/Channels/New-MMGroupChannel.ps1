# Создание группового канала (GM) для нескольких пользователей

function New-MMGroupChannel {
    <#
    .SYNOPSIS
        Creates a group message channel for 3–8 MatterMost users.
    .DESCRIPTION
        Calls POST /channels/group with an array of 3 to 8 user IDs.
        If the group channel already exists for the same set of users, MatterMost returns the existing one.
        Used internally by Send-MMMessage and Get-MMMessage when multiple recipients are specified.
    .PARAMETER UserIds
        An array of 3 to 8 user IDs to include in the group channel.
    .OUTPUTS
        MMChannel. The group channel object (existing or newly created).
    .EXAMPLE
        New-MMGroupChannel -UserIds 'id1', 'id2', 'id3'
    .EXAMPLE
        $ids = (Get-MMUser -Usernames 'alice', 'bob', 'charlie').id
        New-MMGroupChannel -UserIds $ids
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
