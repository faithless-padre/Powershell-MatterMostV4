# Обновление профиля пользователя MatterMost

function Set-MMUser {
    <#
    .SYNOPSIS
        Updates a MatterMost user profile (PUT /users/{id}/patch).
    .DESCRIPTION
        Sends PUT /users/{user_id}/patch to partially update user profile fields.
        Only parameters you specify are included in the request — unspecified fields remain unchanged.
        Use -Properties to set arbitrary API fields not covered by named parameters.
    .PARAMETER UserId
        The ID of the user to update. Accepts pipeline input by property name (id).
    .PARAMETER Email
        The new email address for the user.
    .PARAMETER Username
        The new username (must be unique on the server).
    .PARAMETER FirstName
        The user's first name.
    .PARAMETER LastName
        The user's last name.
    .PARAMETER Nickname
        The user's display nickname.
    .PARAMETER Locale
        The UI locale, e.g. 'en', 'ru', 'de'.
    .PARAMETER Position
        The user's job position or title shown in their profile.
    .PARAMETER Timezone
        A hashtable with timezone settings: useAutomaticTimezone, manualTimezone, automaticTimezone.
    .PARAMETER Props
        A hashtable of custom user properties (props field in the API).
    .PARAMETER NotifyProps
        A hashtable of notification preferences (email, push, desktop settings, etc).
    .PARAMETER Properties
        A hashtable of arbitrary API fields to include in the PATCH body. Useful for new or undocumented fields.
    .OUTPUTS
        MMUser. The updated user object.
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
