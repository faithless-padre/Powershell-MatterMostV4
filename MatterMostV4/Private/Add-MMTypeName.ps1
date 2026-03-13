# Хелпер для навешивания TypeName на PSCustomObject из API-ответа

function Add-MMTypeName {
    <#
    .SYNOPSIS
        Добавляет TypeName к PSCustomObject, чтобы сработали Format.ps1xml-представления.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$TypeName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $InputObject.PSObject.TypeNames.Insert(0, $TypeName)
        $InputObject
    }
}
