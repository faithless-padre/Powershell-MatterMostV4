# Конвертирует PSCustomObject из API в типизированный объект MMPost

function ConvertTo-MMPost {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMPost.
    #>
    [OutputType('MMPost')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMPost].GetProperties().Name

        $post = [MMPost]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $post.$($prop.Name) = $prop.Value
            } else {
                $post.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $post
    }
}
