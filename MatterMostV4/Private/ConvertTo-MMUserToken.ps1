# Конвертирует PSCustomObject из API в типизированный объект MMUserToken

function ConvertTo-MMUserToken {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMUserToken object.
    #>
    [OutputType('MMUserToken')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMUserToken].GetProperties().Name

        $obj = [MMUserToken]::new()
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
