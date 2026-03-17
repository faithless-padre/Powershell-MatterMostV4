# Конвертирует PSCustomObject из API в типизированный объект MMIncomingWebhook

function ConvertTo-MMIncomingWebhook {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMIncomingWebhook object.
    #>
    [OutputType('MMIncomingWebhook')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMIncomingWebhook].GetProperties().Name

        $hook = [MMIncomingWebhook]::new()
        foreach ($prop in $InputObject.PSObject.Properties) {
            if ($prop.Name -in $knownFields) {
                $hook.$($prop.Name) = $prop.Value
            } else {
                $hook.ExtendedFields[$prop.Name] = $prop.Value
            }
        }
        $hook
    }
}
