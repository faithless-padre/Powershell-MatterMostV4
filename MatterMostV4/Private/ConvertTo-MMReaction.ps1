# Конвертирует PSCustomObject из API в типизированный объект MMReaction

function ConvertTo-MMReaction {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMReaction.
    #>
    [OutputType('MMReaction')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMReaction].GetProperties().Name

        $reaction = [MMReaction]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $reaction.$($prop.Name) = $prop.Value
            } else {
                $reaction.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $reaction
    }
}
