# Конвертирует PSCustomObject из API в типизированный объект MMRole

function ConvertTo-MMRole {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMRole.
    #>
    [OutputType('MMRole')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMRole].GetProperties().Name

        $role = [MMRole]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $role.$($prop.Name) = $prop.Value
            } else {
                $role.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $role
    }
}
