# Get-MMErrorMessage.ps1 — Извлекает читаемое сообщение из ошибки MatterMost API

function Get-MMErrorMessage {
    <#
    .SYNOPSIS
        Парсит ErrorDetails из исключения и возвращает читаемое сообщение MatterMost API.
    #>
    param(
        [Parameter(Mandatory)]
        $ErrorRecord
    )

    $raw = $ErrorRecord.ErrorDetails.Message
    if ($raw) {
        try {
            $json = $raw | ConvertFrom-Json
            if ($json.message) { return $json.message }
        }
        catch {}
    }

    return $ErrorRecord.Exception.Message
}
