# Создание нового канала в MatterMost

function New-MMChannel {
    <#
    .SYNOPSIS
        Создаёт новый канал в команде MatterMost.
    .EXAMPLE
        New-MMChannel -TeamId 'team123' -Name 'mychannel' -DisplayName 'My Channel'
    .EXAMPLE
        New-MMChannel -TeamId 'team123' -Name 'private' -DisplayName 'Private Channel' -Type Private
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        # Public — открытый канал, Private — закрытый
        [ValidateSet('Public', 'Private')]
        [string]$Type = 'Public',

        [string]$Purpose,
        [string]$Header
    )

    $body = @{
        team_id      = $TeamId
        name         = $Name
        display_name = $DisplayName
        type         = if ($Type -eq 'Public') { 'O' } else { 'P' }
    }

    if ($Purpose) { $body['purpose'] = $Purpose }
    if ($Header)  { $body['header']  = $Header }

    Invoke-MMRequest -Endpoint 'channels' -Method POST -Body $body
}
