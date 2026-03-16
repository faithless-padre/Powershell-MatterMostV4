# Обновление профиля пользователя MatterMost

function Set-MMUser {
    <#
    .SYNOPSIS
        Обновляет профиль пользователя MatterMost (PUT /users/{id}/patch).
    .EXAMPLE
        Set-MMUser -UserId 'abc123' -FirstName 'Ivan' -LastName 'Petrov'
    .EXAMPLE
        Get-MMUser admin | Set-MMUser -Nickname 'Boss' -Position 'CTO'
    .EXAMPLE
        Set-MMUser -UserId 'abc123' -Timezone @{ useAutomaticTimezone = 'false'; manualTimezone = 'Europe/Moscow' }
    .EXAMPLE
        Set-MMUser -UserId 'abc123' -Properties @{ new_field = 'value' }
    #>
    [OutputType('MMUser')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [string]$Email,
        [string]$Username,
        [string]$FirstName,
        [string]$LastName,
        [string]$Nickname,
        [string]$Locale,
        [string]$Position,
        [hashtable]$Timezone,
        [hashtable]$Props,
        [hashtable]$NotifyProps,

        # Произвольные поля — для новых или незадокументированных свойств API
        [hashtable]$Properties
    )

    process {
        $paramMap = @{
            Email       = 'email'
            Username    = 'username'
            FirstName   = 'first_name'
            LastName    = 'last_name'
            Nickname    = 'nickname'
            Locale      = 'locale'
            Position    = 'position'
            Timezone    = 'timezone'
            Props       = 'props'
            NotifyProps = 'notify_props'
        }

        $body = @{}
        foreach ($param in $paramMap.Keys) {
            if ($PSBoundParameters.ContainsKey($param)) {
                $body[$paramMap[$param]] = $PSBoundParameters[$param]
            }
        }
        if ($Properties) {
            foreach ($key in $Properties.Keys) { $body[$key] = $Properties[$key] }
        }

        Invoke-MMRequest -Endpoint "users/$UserId/patch" -Method PUT -Body $body | ConvertTo-MMUser
    }
}
