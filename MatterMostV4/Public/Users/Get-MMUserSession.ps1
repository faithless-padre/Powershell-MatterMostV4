# Получение активных сессий пользователя MatterMost

function Get-MMUserSession {
    <#
    .SYNOPSIS
        Returns the list of active sessions for a MatterMost user.
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
