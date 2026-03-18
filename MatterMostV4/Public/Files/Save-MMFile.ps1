# Скачивает файл с MatterMost сервера на локальный диск

function Save-MMFile {
    <#
    .SYNOPSIS
        Downloads a file from MatterMost to the local filesystem.
    .DESCRIPTION
        Fetches the file binary from /files/{file_id} and saves it to the specified location.
        If FileName is not provided via pipeline, the metadata is fetched automatically to determine the filename.
    .PARAMETER FileId
        The ID of the file to download. Accepts pipeline input by property name (id).
    .PARAMETER FileName
        The filename to save as. When piped from Send-MMFile or Get-MMFileMetadata, this is populated automatically.
    .PARAMETER DestinationPath
        The local directory where the file will be saved. Defaults to the current directory.
    .OUTPUTS
        System.IO.FileInfo. A FileInfo object pointing to the downloaded file.
    .EXAMPLE
        Save-MMFile -FileId 'abc123' -DestinationPath 'C:\Downloads'
    .EXAMPLE
        Send-MMFile -FilePath 'C:\doc.pdf' -ChannelId 'xyz' | Save-MMFile -DestinationPath 'C:\Downloads'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$FileId,

        # Имя файла для сохранения — берётся из метаданных если не передано через пайп
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('name')]
        [string]$FileName,

        [Parameter()]
        [string]$DestinationPath = (Get-Location).Path
    )

    process {
        if (-not $script:MMSession) {
            throw "Not connected. Run Connect-MMServer first."
        }

        # Если имя не пришло из пайпа — запрашиваем метаданные
        if (-not $FileName) {
            $meta     = Get-MMFileMetadata -FileId $FileId
            $FileName = $meta.name
        }

        $outPath = Join-Path $DestinationPath $FileName

        $uri     = "$($script:MMSession.Url)/api/v4/files/$FileId"
        $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }

        try {
            Invoke-RestMethod -Uri $uri -Headers $headers -OutFile $outPath
            Write-Verbose "Saved: $outPath"
            [System.IO.FileInfo]$outPath
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "MM API error [$statusCode] on GET /api/v4/files/$FileId : $(Get-MMErrorMessage $_)"
        }
    }
}
