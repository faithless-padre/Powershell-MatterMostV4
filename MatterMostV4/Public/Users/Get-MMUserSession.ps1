# Получение активных сессий пользователя MatterMost

function Get-MMUserSession {
    <#
    .SYNOPSIS
        Returns the list of active sessions for a MatterMost user.
    .DESCRIPTION
        Calls GET /users/{user_id}/sessions to retrieve all active login sessions.
        Each MMSession object includes session ID, device type, creation time, last activity, and user agent.
        Use Revoke-MMUserSession or Revoke-MMAllUserSessions to terminate sessions.
    .PARAMETER UserId
        The ID of the user. Used with the ById parameter set. Accepts pipeline input by property name (id).
    .PARAMETER Username
        The username of the user. Used with the ByName parameter set.
    .OUTPUTS
        MMSession. One or more session objects.
    .EXAMPLE
        Get-MMUserSession -UserId 'abc123'
    .EXAMPLE
        Get-MMUserSession -Username 'jdoe'
    .EXAMPLE
        Get-MMUser -Username 'jdoe' | Get-MMUserSession
    #>
    [OutputType('MMSession')]
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ByName')]
        [string]$Username
    )

    process {
        $resolvedId = if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            (Get-MMUser -Username $Username).id
        } else {
            $UserId
        }

        Invoke-MMRequest -Endpoint "users/$resolvedId/sessions" | ConvertTo-MMSession
    }
}
