# Конвертирует PSCustomObject из API в типизированный объект MMChannel

function ConvertTo-MMChannel {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMChannel.
    #>
    [OutputType('MMChannel')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMChannel].GetProperties().Name

        $channel = [MMChannel]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $channel.$($prop.Name) = $prop.Value
            } else {
                $channel.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $channel
    }
}
