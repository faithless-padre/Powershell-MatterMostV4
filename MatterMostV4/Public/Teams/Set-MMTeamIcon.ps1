# Загрузка иконки команды MatterMost

function Set-MMTeamIcon {
    <#
    .SYNOPSIS
        Uploads an image file as the team icon via multipart/form-data.
    .PARAMETER TeamId
        The ID of the team. Accepts pipeline input by property name.
    .PARAMETER FilePath
        The local path to the image file to upload.
    .EXAMPLE
        Set-MMTeamIcon -TeamId 'abc123' -FilePath 'C:\icons\team.png'
    .EXAMPLE
        Get-MMTeam -Name 'dev' | Set-MMTeamIcon -FilePath '/home/user/dev-logo.png'
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$TeamId,

        [Parameter(Mandatory)]
        [string]$FilePath
    )

    process {
        if (-not $script:MMSession) {
            throw "Not connected. Run Connect-MMServer first."
        }

        if (-not (Test-Path -LiteralPath $FilePath)) {
            throw "File not found: $FilePath"
        }

        if ($PSCmdlet.ShouldProcess($TeamId, "Upload team icon from '$FilePath'")) {
            $uri      = "$($script:MMSession.Url)/api/v4/teams/$TeamId/image"
            $fileName = [System.IO.Path]::GetFileName($FilePath)
            $bytes    = [System.IO.File]::ReadAllBytes($FilePath)

            $client = [System.Net.Http.HttpClient]::new()
            try {
                $client.DefaultRequestHeaders.Add('Authorization', "Bearer $($script:MMSession.Token)")

                $multipart = [System.Net.Http.MultipartFormDataContent]::new()
                try {
                    $fileContent = [System.Net.Http.ByteArrayContent]::new($bytes)
                    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')
                    $multipart.Add($fileContent, 'image', $fileName)

                    $response = $client.PostAsync($uri, $multipart).Result

                    if (-not $response.IsSuccessStatusCode) {
                        $body = $response.Content.ReadAsStringAsync().Result
                        throw "MM API error [$($response.StatusCode.value__)] on POST /api/v4/teams/$TeamId/image : $body"
                    }

                    Write-Verbose "Team icon uploaded successfully for team '$TeamId'."
                }
                finally {
                    $multipart.Dispose()
                }
            }
            finally {
                $client.Dispose()
            }
        }
    }
}
