# Создание нового пользователя в MatterMost

function New-MMUser {
    <#
    .SYNOPSIS
        Создаёт нового пользователя в MatterMost.
    .EXAMPLE
        New-MMUser -Username 'jdoe' -Email 'jdoe@example.com' -Password (ConvertTo-SecureString 'Pass123!' -AsPlainText -Force)
    .EXAMPLE
        New-MMUser -Username 'jdoe' -Email 'jdoe@example.com' -Password (ConvertTo-SecureString 'Pass123!' -AsPlainText -Force) -FirstName 'John' -LastName 'Doe'
    .EXAMPLE
        $users | New-MMUser
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Username,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Email,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [SecureString]$Password,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$FirstName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$LastName,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Nickname,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$Locale = 'en'
    )

    process {
        $body = @{
            username = $Username
            email    = $Email
            password = [System.Net.NetworkCredential]::new('', $Password).Password
            locale   = $Locale
        }

        if ($FirstName) { $body['first_name'] = $FirstName }
        if ($LastName)  { $body['last_name']  = $LastName }
        if ($Nickname)  { $body['nickname']   = $Nickname }

        Invoke-MMRequest -Endpoint 'users' -Method POST -Body $body | Add-MMTypeName -TypeName 'MatterMost.User'
    }
}
