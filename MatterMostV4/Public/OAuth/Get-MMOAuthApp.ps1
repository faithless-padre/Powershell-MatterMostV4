# Получение OAuth-приложений MatterMost

function Get-MMOAuthApp {
    <#
    .SYNOPSIS
        Returns OAuth apps. All apps (paginated) or a specific app by ID.
    .EXAMPLE
        Get-MMOAuthApp
    .EXAMPLE
        Get-MMOAuthApp -AppId 'abc123'
    #>
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [int]$Page = 0,

        [Parameter(ParameterSetName = 'All')]
        [int]$PerPage = 200,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$AppId
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                Invoke-MMRequest -Endpoint "oauth/apps/$AppId" -Method GET
            }
            'All' {
                Invoke-MMRequest -Endpoint "oauth/apps?page=$Page&per_page=$PerPage" -Method GET
            }
        }
    }
}
