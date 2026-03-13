# Внутренний хелпер для выполнения HTTP запросов к MatterMost REST API

function Invoke-MMRequest {
    <#
    .SYNOPSIS
        Выполняет HTTP запрос к MatterMost API, используя сохранённую сессию.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Endpoint,

        [string]$Method = 'GET',

        [object]$Body,

        [hashtable]$AdditionalHeaders = @{}
    )

    if (-not $script:MMSession) {
        throw "Not connected. Run Connect-MMServer first."
    }

    $headers = @{
        'Content-Type'  = 'application/json'
        'Authorization' = "Bearer $($script:MMSession.Token)"
    }

    foreach ($key in $AdditionalHeaders.Keys) {
        $headers[$key] = $AdditionalHeaders[$key]
    }

    $params = @{
        Uri     = "$($script:MMSession.Url)/api/v4/$Endpoint"
        Method  = $Method
        Headers = $headers
    }

    if ($Body) {
        $params['Body'] = ($Body | ConvertTo-Json -Depth 10)
    }

    try {
        Invoke-RestMethod @params
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        throw "MM API error [$statusCode] on $Method /api/v4/$Endpoint : $($_.ErrorDetails.Message)"
    }
}
