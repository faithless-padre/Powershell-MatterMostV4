# Конвертирует PSCustomObject из API в типизированный объект MMOutgoingWebhook

function ConvertTo-MMOutgoingWebhook {
    <#
    .SYNOPSIS
        Converts a MatterMost API response to an MMOutgoingWebhook object.
    #>
    [OutputType('MMOutgoingWebhook')]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object]$InputObject
    )

    process {
        $knownFields = [MMOutgoingWebhook].GetProperties().Name

        $hook = [MMOutgoingWebhook]::new()
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
