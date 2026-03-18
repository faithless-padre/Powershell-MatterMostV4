# Создание канала прямых сообщений (DM) между двумя пользователями

function New-MMDirectChannel {
    <#
    .SYNOPSIS
        Creates a direct message (DM) channel between two MatterMost users.
    .DESCRIPTION
        Calls POST /channels/direct with an array of two user IDs. If the DM channel already exists,
        MatterMost returns the existing one. Used internally by Send-MMMessage and Get-MMMessage.
    .PARAMETER UserId1
        The ID of the first user. Accepts pipeline input by property name (id).
    .PARAMETER UserId2
        The ID of the second user.
    .OUTPUTS
        MMChannel. The DM channel object (existing or newly created).
    .EXAMPLE
        New-MMDirectChannel -UserId1 'abc123' -UserId2 'def456'
    .EXAMPLE
        Get-MMUser -Username 'john' | New-MMDirectChannel -UserId2 'def456'
    #>
    [CmdletBinding()]
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId1,

        [Parameter(Mandatory)]
        [string]$UserId2
    )

    process {
        Invoke-MMRequest -Endpoint 'channels/direct' -Method POST -Body @($UserId1, $UserId2) |
            ConvertTo-MMChannel
    }
}
