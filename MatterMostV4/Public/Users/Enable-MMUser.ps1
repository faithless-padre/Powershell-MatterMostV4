# Активация деактивированного пользователя MatterMost

function Enable-MMUser {
    <#
    .SYNOPSIS
        Активирует деактивированного пользователя MatterMost.
    .EXAMPLE
        Enable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -UserId 'abc123' | Enable-MMUser
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $true }
    }
}
