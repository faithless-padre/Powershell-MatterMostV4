# Creates a new custom emoji in MatterMost

function New-MMEmoji {
    <#
    .SYNOPSIS
        Creates a new custom emoji in MatterMost from an image file.
    .DESCRIPTION
        Uploads an image and registers it as a custom emoji via POST /emoji using multipart form data.
        Supported formats: PNG, GIF, JPG. If CreatorId is not specified, the currently connected user is used.
        Requires the "Enable Custom Emoji" system setting to be active.
    .PARAMETER Name
        The emoji shortcode name (without colons), e.g. 'party-parrot'. Must be unique.
    .PARAMETER ImagePath
        The local filesystem path to the image file to upload.
    .PARAMETER CreatorId
        The user ID to associate as the emoji creator. Defaults to the current session user.
    .OUTPUTS
        MMEmoji. The newly created emoji object.
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
