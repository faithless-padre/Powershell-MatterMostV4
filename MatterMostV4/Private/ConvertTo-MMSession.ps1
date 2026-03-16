# Конвертирует PSCustomObject из API в типизированный объект MMSession

function ConvertTo-MMSession {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMSession.
    #>
    [OutputType('MMSession')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMSession].GetProperties().Name

        $session = [MMSession]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $session.$($prop.Name) = $prop.Value
            } else {
                $session.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $session
    }
}
