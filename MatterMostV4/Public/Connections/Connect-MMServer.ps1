# Устанавливает соединение с MatterMost сервером и сохраняет сессию в модуле

function Connect-MMServer {
    <#
    .SYNOPSIS
        Connects to a MatterMost server and stores the session token for subsequent requests.
    .DESCRIPTION
        Поддерживает три способа аутентификации: PSCredential, Username/Password или Personal Access Token.
        После успешного подключения токен сохраняется в $script:MMSession и используется автоматически всеми командлетами модуля.
    .EXAMPLE
        Connect-MMServer -Url "http://localhost:8065" -Username "admin" -Password (ConvertTo-SecureString "Admin123456!" -AsPlainText -Force)
    .EXAMPLE
        Connect-MMServer -Url "http://localhost:8065" -Credential (Get-Credential)
    .EXAMPLE
        Connect-MMServer -Url "http://localhost:8065" -Token "your-personal-access-token"
    #>
    [CmdletBinding(DefaultParameterSetName = 'Credential')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Credential')]
        [Parameter(Mandatory, ParameterSetName = 'UsernamePassword')]
        [Parameter(Mandatory, ParameterSetName = 'Token')]
        [string]$Url,

        # --- ParameterSet: Credential ---
        [Parameter(Mandatory, ParameterSetName = 'Credential')]
        [System.Management.Automation.PSCredential]$Credential,

        # --- ParameterSet: UsernamePassword ---
        [Parameter(Mandatory, ParameterSetName = 'UsernamePassword')]
        [string]$Username,

        [Parameter(Mandatory, ParameterSetName = 'UsernamePassword')]
        [SecureString]$Password,

        # --- ParameterSet: Token ---
        [Parameter(Mandatory, ParameterSetName = 'Token')]
        [string]$Token,

        # --- Общий опциональный параметр ---
        [Parameter(ParameterSetName = 'Credential')]
        [Parameter(ParameterSetName = 'UsernamePassword')]
        [Parameter(ParameterSetName = 'Token')]
        [string]$DefaultTeam
    )

    $Url = $Url.TrimEnd('/')

    if ($PSCmdlet.ParameterSetName -in @('Credential', 'UsernamePassword')) {

        if ($PSCmdlet.ParameterSetName -eq 'Credential') {
            $loginId = $Credential.UserName
            $plainPassword = $Credential.GetNetworkCredential().Password
        }
        else {
            $loginId = $Username
            $plainPassword = [PSCredential]::new('x', $Password).GetNetworkCredential().Password
        }

        $body = @{ login_id = $loginId; password = $plainPassword } | ConvertTo-Json

        try {
            $response = Invoke-WebRequest -Uri "$Url/api/v4/users/login" `
                -Method POST `
                -Body $body `
                -ContentType 'application/json'
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "Login failed [$statusCode]: $(Get-MMErrorMessage $_)"
        }

        $sessionToken = $response.Headers['Token']
        if ($sessionToken -is [array]) { $sessionToken = $sessionToken[0] }

        $userInfo = $response.Content | ConvertFrom-Json

        $script:MMSession = @{
            Url      = $Url
            Token    = $sessionToken
            AuthType = 'SessionToken'
            UserId   = $userInfo.id
            Username = $userInfo.username
        }
    }
    else {
        # Token — validate by calling /users/me
        try {
            $me = Invoke-RestMethod -Uri "$Url/api/v4/users/me" `
                -Method GET `
                -Headers @{ Authorization = "Bearer $Token" }
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "Token validation failed [$statusCode]: $(Get-MMErrorMessage $_)"
        }

        $script:MMSession = @{
            Url      = $Url
            Token    = $Token
            AuthType = 'PersonalToken'
            UserId   = $me.id
            Username = $me.username
        }
    }

    if ($DefaultTeam) {
        try {
            $team = Invoke-MMRequest -Endpoint "teams/name/$DefaultTeam"
            $script:MMSession.DefaultTeamId = $team.id
        }
        catch {
            throw "DefaultTeam '$DefaultTeam' not found: $(Get-MMErrorMessage $_)"
        }
    }

    Write-Verbose "Connected to $Url as '$($script:MMSession.Username)' [$($script:MMSession.AuthType)]"

    [PSCustomObject]@{
        Url           = $script:MMSession.Url
        Username      = $script:MMSession.Username
        UserId        = $script:MMSession.UserId
        AuthType      = $script:MMSession.AuthType
        DefaultTeamId = $script:MMSession.DefaultTeamId
    }
}
