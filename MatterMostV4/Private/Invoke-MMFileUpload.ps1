# Внутренний хелпер для загрузки файлов через multipart/form-data (совместим с PS 5.1+)

function Invoke-MMFileUpload {
    <#
    .SYNOPSIS
        Загружает файл на MatterMost сервер через multipart/form-data.
    #>
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [string]$ChannelId
    )

    if (-not $script:MMSession) {
        throw "Not connected. Run Connect-MMServer first."
    }

    if (-not (Test-Path -LiteralPath $FilePath)) {
        throw "File not found: $FilePath"
    }

    $uri      = "$($script:MMSession.Url)/api/v4/files"
    $fileName = [System.IO.Path]::GetFileName($FilePath)
    $bytes    = [System.IO.File]::ReadAllBytes($FilePath)

    $client = [System.Net.Http.HttpClient]::new()
    try {
        $client.DefaultRequestHeaders.Add('Authorization', "Bearer $($script:MMSession.Token)")

        $multipart = [System.Net.Http.MultipartFormDataContent]::new()
        try {
            $fileContent = [System.Net.Http.ByteArrayContent]::new($bytes)
            $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')
            $multipart.Add($fileContent, 'files', $fileName)
            $multipart.Add([System.Net.Http.StringContent]::new($ChannelId), 'channel_id')

            $response = $client.PostAsync($uri, $multipart).Result

            if (-not $response.IsSuccessStatusCode) {
                $body = $response.Content.ReadAsStringAsync().Result
                throw "MM API error [$($response.StatusCode.value__)] on POST /api/v4/files : $body"
            }

            $json    = $response.Content.ReadAsStringAsync().Result
            $result  = $json | ConvertFrom-Json

            # Возвращаем первый file_info из массива
            $result.file_infos | ForEach-Object { $_ }
        }
        finally {
            $multipart.Dispose()
        }
    }
    finally {
        $client.Dispose()
    }
}
