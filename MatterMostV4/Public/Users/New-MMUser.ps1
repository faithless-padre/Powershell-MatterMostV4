# Создание нового пользователя в MatterMost

function New-MMUser {
    <#
    .SYNOPSIS
        Creates a new user in MatterMost.
    .DESCRIPTION
        Sends POST /users to create a new user account. Username and email must be unique on the server.
        Password is accepted as SecureString and converted internally — never passed as plaintext.
        All pipeline-bindable parameters support bulk creation from a collection of objects.
    .PARAMETER Username
        The unique login name for the user (lowercase, alphanumeric, hyphens, underscores, periods).
    .PARAMETER Email
        The unique email address for the user's account.
    .PARAMETER Password
        The initial password as a SecureString. Use ConvertTo-SecureString to create one.
    .PARAMETER FirstName
        The user's first name (optional, displayed in profile).
    .PARAMETER LastName
        The user's last name (optional, displayed in profile).
    .PARAMETER Nickname
        An optional display nickname shown instead of the full name in some UI contexts.
    .PARAMETER Locale
        The UI locale for the user, e.g. 'en', 'ru', 'de'. Defaults to 'en'.
    .OUTPUTS
        MMUser. The newly created user object.
    .EXAMPLE
        New-MMUser -Username 'jdoe' -Email 'jdoe@example.com' -Password (ConvertTo-SecureString 'Pass123!' -AsPlainText -Force)
    .EXAMPLE
        New-MMUser -Username 'jdoe' -Email 'jdoe@example.com' -Password (ConvertTo-SecureString 'Pass123!' -AsPlainText -Force) -FirstName 'John' -LastName 'Doe'
    .EXAMPLE
        $users | New-MMUser
    #>
    [OutputType('MMUser')]
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

        Invoke-MMRequest -Endpoint 'users' -Method POST -Body $body | ConvertTo-MMUser
    }
}
