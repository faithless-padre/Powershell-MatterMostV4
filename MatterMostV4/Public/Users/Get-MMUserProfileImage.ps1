# Скачивание аватара пользователя MatterMost

function Get-MMUserProfileImage {
    <#
    .SYNOPSIS
        Downloads the profile image of a MatterMost user to a local file.
    .PARAMETER UserId
        The ID of the user whose profile image to download. Accepts pipeline input by property name (id).
    .PARAMETER OutputPath
        The local file path where the image will be saved.
    .OUTPUTS
        System.Void. The image is written to disk at OutputPath.
    .EXAMPLE
        Get-MMUserProfileImage -UserId 'abc123' -OutputPath 'C:\temp\avatar.png'
    .EXAMPLE
        Get-MMUser -Me | Get-MMUserProfileImage -OutputPath '/tmp/me.png'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    process {
        $uri     = "$($script:MMSession.Url)/api/v4/users/$UserId/image"
        $headers = @{ Authorization = "Bearer $($script:MMSession.Token)" }
        Invoke-RestMethod -Uri $uri -Method GET -Headers $headers -OutFile $OutputPath
    }
}
