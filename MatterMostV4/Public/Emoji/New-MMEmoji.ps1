# Creates a new custom emoji in MatterMost

function New-MMEmoji {
    <#
    .SYNOPSIS
        Creates a new custom emoji in MatterMost from an image file.
    .EXAMPLE
        New-MMEmoji -Name 'myemoji' -ImagePath 'C:\emoji.png'
    .EXAMPLE
        New-MMEmoji -Name 'myemoji' -ImagePath 'C:\emoji.gif' -CreatorId 'abc123'
    #>
    [CmdletBinding()]
    [OutputType('MMEmoji')]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$ImagePath,

        [Parameter()]
        [string]$CreatorId
    )

    if (-not $script:MMSession) {
        throw 'Not connected. Run Connect-MMServer first.'
    }

    if (-not (Test-Path -LiteralPath $ImagePath)) {
        throw "Image file not found: $ImagePath"
    }

    $resolvedCreatorId = if ($CreatorId) { $CreatorId } else { $script:MMSession.UserId }

    $uri      = "$($script:MMSession.Url)/api/v4/emoji"
    $fileName = [System.IO.Path]::GetFileName($ImagePath)
    $bytes    = [System.IO.File]::ReadAllBytes($ImagePath)

    $emojiJson = @{ name = $Name; creator_id = $resolvedCreatorId } | ConvertTo-Json -Compress

    $client = [System.Net.Http.HttpClient]::new()
    try {
        $client.DefaultRequestHeaders.Add('Authorization', "Bearer $($script:MMSession.Token)")

        $multipart = [System.Net.Http.MultipartFormDataContent]::new()
        try {
            $imageContent = [System.Net.Http.ByteArrayContent]::new($bytes)
            $imageContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse('application/octet-stream')
            $multipart.Add($imageContent, 'image', $fileName)
            $multipart.Add([System.Net.Http.StringContent]::new($emojiJson), 'emoji')

            $response = $client.PostAsync($uri, $multipart).Result

            if (-not $response.IsSuccessStatusCode) {
                $body = $response.Content.ReadAsStringAsync().Result
                throw "MM API error [$($response.StatusCode.value__)] on POST /api/v4/emoji : $body"
            }

            $response.Content.ReadAsStringAsync().Result | ConvertFrom-Json | ConvertTo-MMEmoji
        }
        finally {
            $multipart.Dispose()
        }
    }
    finally {
        $client.Dispose()
    }
}
