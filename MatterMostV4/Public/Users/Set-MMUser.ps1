# Обновление профиля пользователя MatterMost

function Set-MMUser {
    <#
    .SYNOPSIS
        Обновляет профиль пользователя MatterMost.
    .EXAMPLE
        Set-MMUser -UserId 'abc123' -FirstName 'John' -LastName 'Doe'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Set-MMUser -Nickname 'JD'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Email,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Nickname,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Position,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Locale
    )

    process {
        # Получаем текущий профиль чтобы не потерять обязательные поля
        $current = Invoke-MMRequest -Endpoint "users/$UserId"

        $body = @{
            id       = $UserId
            username = if ($Username) { $Username } else { $current.username }
            email    = if ($Email)    { $Email }    else { $current.email }
        }

        if ($PSBoundParameters.ContainsKey('FirstName')) { $body['first_name'] = $FirstName }
        else { $body['first_name'] = $current.first_name }

        if ($PSBoundParameters.ContainsKey('LastName'))  { $body['last_name']  = $LastName }
        else { $body['last_name'] = $current.last_name }

        if ($PSBoundParameters.ContainsKey('Nickname'))  { $body['nickname']   = $Nickname }
        else { $body['nickname'] = $current.nickname }

        if ($PSBoundParameters.ContainsKey('Position'))  { $body['position']   = $Position }
        else { $body['position'] = $current.position }

        if ($PSBoundParameters.ContainsKey('Locale'))    { $body['locale']     = $Locale }
        else { $body['locale'] = $current.locale }

        Invoke-MMRequest -Endpoint "users/$UserId" -Method PUT -Body $body
    }
}
