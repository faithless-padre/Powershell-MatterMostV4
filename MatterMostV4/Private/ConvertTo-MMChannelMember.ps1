# Конвертер PSCustomObject → MMChannelMember

function ConvertTo-MMChannelMember {
    <#
    .SYNOPSIS
        Конвертирует ответ API в объект типа MMChannelMember.
    #>
    [CmdletBinding()]
    [OutputType([MMChannelMember])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = @('channel_id','user_id','roles','last_viewed_at','msg_count',
                         'mention_count','mention_count_root','notify_props','last_update_at')

        $obj = [MMChannelMember]::new()
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
