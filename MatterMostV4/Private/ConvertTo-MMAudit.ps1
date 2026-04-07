# Converts a raw API response object to an MMAudit instance

function ConvertTo-MMAudit {
    <#
    .SYNOPSIS
        Преобразует объект API-ответа в тип MMAudit.
    #>
    [OutputType('MMAudit')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMAudit].GetProperties().Name
        $obj = [MMAudit]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) { $obj.$($prop.Name) = $prop.Value }
            else { $obj.ExtendedFields[$prop.Name] = $prop.Value }
        }
        $obj
    }
}
