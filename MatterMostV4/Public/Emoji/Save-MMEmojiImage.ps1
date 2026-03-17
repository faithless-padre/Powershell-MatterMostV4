# Downloads a custom emoji image from MatterMost

function Save-MMEmojiImage {
    <#
    .SYNOPSIS
        Downloads a MatterMost custom emoji image to the local filesystem.
    .EXAMPLE
        Save-MMEmojiImage -EmojiId 'abc123' -DestinationPath 'C:\emoji.png'
    .EXAMPLE
        Get-MMEmoji -Name 'myemoji' | Save-MMEmojiImage -DestinationPath 'C:\Downloads'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$EmojiId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$EmojiName,

        [Parameter()]
        [string]$DestinationPath
    )

    process {
        if (-not $script:MMSession) {
            throw 'Not connected. Run Connect-MMServer first.'
        }

        $uri = "$($script:MMSession.Url)/api/v4/emoji/$EmojiId/image"
        $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }

        try {
            $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method GET
        } catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "MM API error [$statusCode] on GET /api/v4/emoji/$EmojiId/image : $(Get-MMErrorMessage $_)"
        }

        # Определяем расширение из Content-Type
        $contentType = $response.Headers['Content-Type']
        $ext = switch -Wildcard ($contentType) {
            '*gif*'  { '.gif' }
            '*png*'  { '.png' }
            '*jpeg*' { '.jpg' }
            default  { '.png' }
        }

        # Определяем путь назначения
        $fileName = if ($EmojiName) { "$EmojiName$ext" } else { "$EmojiId$ext" }

        $dest = if ($DestinationPath -and (Test-Path -LiteralPath $DestinationPath -PathType Container)) {
            Join-Path $DestinationPath $fileName
        } elseif ($DestinationPath) {
            $DestinationPath
        } else {
            Join-Path (Get-Location).Path $fileName
        }

        [System.IO.File]::WriteAllBytes($dest, $response.Content)
        Get-Item -LiteralPath $dest
    }
}
