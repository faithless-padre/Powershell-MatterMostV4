# Обновление профиля пользователя MatterMost

function Set-MMUser {
    <#
    .SYNOPSIS
        Обновляет профиль пользователя MatterMost произвольными полями API.
    .EXAMPLE
        Get-MMUser admin | Set-MMUser -Properties @{ nickname = 'Boss' }
    .EXAMPLE
        Set-MMUser -UserId 'abc123' -Properties @{ first_name = 'Ivan'; last_name = 'Petrov' }
    .EXAMPLE
        Get-MMUser admin | Set-MMUser -Properties @{ timezone = @{ useAutomaticTimezone = 'false'; manualTimezone = 'Europe/Moscow' } }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [hashtable]$Properties
    )

    process {
        # Получаем текущий профиль чтобы не потерять обязательные поля (id, username, email)
        $current = Invoke-MMRequest -Endpoint "users/$UserId"

        $body = @{ id = $UserId; username = $current.username; email = $current.email }

        foreach ($key in $Properties.Keys) {
            $body[$key] = $Properties[$key]
        }

        Invoke-MMRequest -Endpoint "users/$UserId" -Method PUT -Body $body
    }
}
