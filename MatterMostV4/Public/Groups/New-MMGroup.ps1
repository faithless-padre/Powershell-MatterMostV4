# Создание кастомной группы MatterMost

function New-MMGroup {
    <#
    .SYNOPSIS
        Создаёт новую кастомную группу MatterMost.
    .EXAMPLE
        New-MMGroup -Name 'devs' -DisplayName 'Developers'
    .EXAMPLE
        New-MMGroup -Name 'devs' -DisplayName 'Developers' -UserIds @('uid1','uid2')
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$DisplayName,

        [string[]]$UserIds = @()
    )

    process {
        $body = @{
            group    = @{
                name            = $Name
                display_name    = $DisplayName
                source          = 'custom'
                allow_reference = $true
            }
            user_ids = $UserIds
        }

        Invoke-MMRequest -Endpoint 'groups' -Method POST -Body $body
    }
}
