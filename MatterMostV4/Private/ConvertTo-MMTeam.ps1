# Конвертирует PSCustomObject из API в типизированный объект MMTeam

function ConvertTo-MMTeam {
    <#
    .SYNOPSIS
        Преобразует ответ MatterMost API в объект типа MMTeam.
    #>
    [OutputType('MMTeam')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMTeam].GetProperties().Name

        $team = [MMTeam]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $team.$($prop.Name) = $prop.Value
            } else {
                $team.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $team
    }
}
