# Конвертирует PSCustomObject из API в MMSidebarCategory

function ConvertTo-MMSidebarCategory {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMSidebarCategory.
    #>
    [OutputType('MMSidebarCategory')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMSidebarCategory].GetProperties().Name
        $obj = [MMSidebarCategory]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) { $obj.$($prop.Name) = $prop.Value }
            else { $obj.ExtendedFields[$prop.Name] = $prop.Value }
        }
        $obj
    }
}
