# Активация деактивированного пользователя MatterMost

function Enable-MMUser {
    <#
    .SYNOPSIS
        Activates a deactivated MatterMost user.
    .EXAMPLE
        Enable-MMUser -UserId 'abc123'
    .EXAMPLE
        Get-MMUser -UserId 'abc123' | Enable-MMUser
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId
    )

    process {
        Invoke-MMRequest -Endpoint "users/$UserId/active" -Method PUT -Body @{ active = $true } | ConvertTo-MMUser
    }
}
