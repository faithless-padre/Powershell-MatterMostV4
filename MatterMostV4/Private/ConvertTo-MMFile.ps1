# Конвертирует PSCustomObject из API в типизированный объект MMFile

function ConvertTo-MMFile {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMFile.
    #>
    [OutputType('MMFile')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMFile].GetProperties().Name

        $file = [MMFile]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $file.$($prop.Name) = $prop.Value
            } else {
                $file.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $file
    }
}
