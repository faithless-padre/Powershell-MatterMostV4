# Скачивание иконки команды MatterMost на диск

function Get-MMTeamIcon {
    <#
    .SYNOPSIS
        Downloads the team icon image and saves it to the specified file path.
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .PARAMETER OutFile
        The local file path where the image will be saved.
    .EXAMPLE
        Get-MMTeamIcon -TeamId 'abc123' -OutFile 'C:\temp\team-icon.png'
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Get-MMTeamIcon -OutFile '/tmp/dev-icon.png'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$OutFile
    )

    process {
        if (-not $script:MMSession) {
            throw "Not connected. Run Connect-MMServer first."
        }

        $uri     = "$($script:MMSession.Url)/api/v4/teams/$TeamId/image"
        $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }

        try {
            Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $OutFile
            Write-Verbose "Saved team icon to: $OutFile"
            [System.IO.FileInfo]$OutFile
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "MM API error [$statusCode] on GET /api/v4/teams/$TeamId/image : $(Get-MMErrorMessage $_)"
        }
    }
}
