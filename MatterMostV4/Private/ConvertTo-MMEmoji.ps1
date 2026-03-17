# Конвертирует PSCustomObject из API в типизированный объект MMEmoji

function ConvertTo-MMEmoji {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMEmoji object.
    #>
    [OutputType('MMEmoji')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMEmoji].GetProperties().Name

        $obj = [MMEmoji]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $obj.$($prop.Name) = $prop.Value
            } else {
                $obj.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $obj
    }
}
