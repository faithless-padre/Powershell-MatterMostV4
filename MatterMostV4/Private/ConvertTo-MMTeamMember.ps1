# Конвертер PSCustomObject → MMTeamMember

function ConvertTo-MMTeamMember {
    <#
    .SYNOPSIS
        Конвертирует ответ API в объект типа MMTeamMember.
    #>
    [CmdletBinding()]
    [OutputType('MMTeamMember')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = @('team_id','user_id','roles','delete_at',
                         'scheme_guest','scheme_user','scheme_admin')

        $obj = [MMTeamMember]::new()
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
