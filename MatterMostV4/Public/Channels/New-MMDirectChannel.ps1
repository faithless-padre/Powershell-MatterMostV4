# Создание канала прямых сообщений (DM) между двумя пользователями

function New-MMDirectChannel {
    <#
    .SYNOPSIS
        Создаёт канал прямых сообщений (DM) между двумя пользователями MatterMost.
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
