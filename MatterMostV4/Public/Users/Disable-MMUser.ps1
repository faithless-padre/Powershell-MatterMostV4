# Деактивация пользователя MatterMost

function Disable-MMUser {
    <#
    .SYNOPSIS
        Деактивирует пользователя MatterMost (soft disable через PUT /active).
    .EXAMPLE
        Disable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser testuser | Disable-MMUser
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $false } | Add-MMTypeName -TypeName 'MatterMost.User'
    }
}
