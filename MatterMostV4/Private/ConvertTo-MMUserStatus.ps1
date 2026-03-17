# Конвертирует PSCustomObject из API в типизированный объект MMUserStatus

function ConvertTo-MMUserStatus {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMUserStatus object.
    #>
    [OutputType('MMUserStatus')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMUserStatus].GetProperties().Name

        $obj = [MMUserStatus]::new()
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
