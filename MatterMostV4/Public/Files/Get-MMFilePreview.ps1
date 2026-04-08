# Скачивание превью файла MatterMost на диск

function Get-MMFilePreview {
    <#
    .SYNOPSIS
        Downloads the preview image for a MatterMost file and saves it to the specified path.
    .PARAMETER FileId
        The ID of the file. Accepts pipeline input by property name.
    .PARAMETER OutFile
        The local file path where the preview will be saved.
    .EXAMPLE
        Get-MMFilePreview -FileId 'abc123' -OutFile 'C:\temp\preview.png'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$FileId,

        [Parameter(Mandatory)]
        [string]$OutFile
    )

    process {
        if (-not $script:MMSession) {
            throw "Not connected. Run Connect-MMServer first."
        }

        $uri     = "$($script:MMSession.Url)/api/v4/files/$FileId/preview"
        $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }

        try {
            Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $OutFile
            Write-Verbose "Saved preview to: $OutFile"
            [System.IO.FileInfo]$OutFile
        }
        catch {
            $statusCode = $_.Exception.Response.StatusCode.value__
            throw "MM API error [$statusCode] on GET /api/v4/files/$FileId/preview : $(Get-MMErrorMessage $_)"
        }
    }
}
