# Установка плагина в MatterMost — по URL или из локального файла

function Install-MMPlugin {
    <#
    .SYNOPSIS
        Installs a plugin on MatterMost, either from a download URL or a local .tar.gz file.
    .EXAMPLE
        Install-MMPlugin -PluginDownloadUrl 'https://example.com/plugin.tar.gz'
    .EXAMPLE
        Install-MMPlugin -PluginDownloadUrl 'https://example.com/plugin.tar.gz' -Force
    .EXAMPLE
        Install-MMPlugin -FilePath '/tmp/myplugin.tar.gz'
    #>
    [CmdletBinding(DefaultParameterSetName = 'FromUrl')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'FromUrl')]
        [string]$PluginDownloadUrl,

        [Parameter(ParameterSetName = 'FromUrl')]
        [switch]$Force,

        [Parameter(Mandatory, ParameterSetName = 'FromFile')]
        [string]$FilePath
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'FromUrl') {
            $body = @{
                plugin_download_url = $PluginDownloadUrl
                force               = $Force.IsPresent
            }
            Invoke-MMRequest -Endpoint 'plugins/install_from_url' -Method POST -Body $body
            return
        }

        # FromFile — multipart upload
        if (-not $script:MMSession) {
            throw "Not connected. Run Connect-MMServer first."
        }

        if (-not (Test-Path -LiteralPath $FilePath)) {
            throw "File not found: $FilePath"
        }

        $uri      = "$($script:MMSession.Url)/api/v4/plugins"
        $fileName = [System.IO.Path]::GetFileName($FilePath)
        $bytes    = [System.IO.File]::ReadAllBytes($FilePath)

        $client = [System.Net.Http.HttpClient]::new()
        try {
            $client.DefaultRequestHeaders.Add('Authorization', "Bearer $($script:MMSession.Token)")

            $multipart = [System.Net.Http.MultipartFormDataContent]::new()
            try {
                $fileContent = [System.Net.Http.ByteArrayContent]::new($bytes)
                $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')
                $multipart.Add($fileContent, 'plugin', $fileName)

                $response = $client.PostAsync($uri, $multipart).Result

                if (-not $response.IsSuccessStatusCode) {
                    $body = $response.Content.ReadAsStringAsync().Result
                    throw "MM API error [$($response.StatusCode.value__)] on POST /api/v4/plugins : $body"
                }

                $json = $response.Content.ReadAsStringAsync().Result
                $json | ConvertFrom-Json
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
