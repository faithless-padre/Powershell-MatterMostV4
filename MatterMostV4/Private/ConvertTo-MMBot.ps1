# Конвертирует PSCustomObject из API в типизированный объект MMBot

function ConvertTo-MMBot {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMBot object.
    #>
    [OutputType('MMBot')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMBot].GetProperties().Name

        $obj = [MMBot]::new()
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
