# Get-MMDefaultTeamId.ps1 — Возвращает TeamId из сессии или выбрасывает исключение

function Get-MMDefaultTeamId {
    <#
    .SYNOPSIS
        Возвращает DefaultTeamId из активной сессии или выбрасывает исключение.
    #>
    if (-not $script:MMSession) {
        throw "Not connected. Run Connect-MMServer first."
    }
    if (-not $script:MMSession.DefaultTeamId) {
        throw "TeamId is required. Specify -TeamId or set a default with Connect-MMServer -DefaultTeam."
    }
    return $script:MMSession.DefaultTeamId
}
