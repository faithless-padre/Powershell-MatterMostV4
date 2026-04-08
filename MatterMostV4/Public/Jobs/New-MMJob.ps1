# Создание нового задания (job) MatterMost

function New-MMJob {
    <#
    .SYNOPSIS
        Создаёт новое задание MatterMost указанного типа.
    .EXAMPLE
        New-MMJob -Type 'elasticsearch-post-indexing'
    .EXAMPLE
        New-MMJob -Type 'ldap-sync' -Data @{ skip_when_ldap_sync_id = 'abc' }
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Type,

        [hashtable]$Data
    )

    process {
        $body = @{ type = $Type }
        if ($PSBoundParameters.ContainsKey('Data')) {
            $body['data'] = $Data
        }

        Invoke-MMRequest -Endpoint 'jobs' -Method POST -Body $body
    }
}
