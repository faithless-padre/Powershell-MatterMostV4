# Конвертирует PSCustomObject из API в типизированный объект MMScheduledPost

function ConvertTo-MMScheduledPost {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMScheduledPost.
    #>
    [OutputType('MMScheduledPost')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMScheduledPost].GetProperties().Name

        $sp = [MMScheduledPost]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $sp.$($prop.Name) = $prop.Value
            } else {
                $sp.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $sp
    }
}
