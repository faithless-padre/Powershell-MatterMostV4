# Конвертирует PSCustomObject из API в типизированный объект MMUser

function ConvertTo-MMUser {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMUser.
    #>
    [OutputType('MMUser')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMUser].GetProperties().Name

        $user = [MMUser]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $user.$($prop.Name) = $prop.Value
            } else {
                $user.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $user
    }
}
