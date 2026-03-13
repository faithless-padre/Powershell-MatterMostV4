# Внутренний хелпер для получения всех команд с пагинацией

function Get-MMTeamList {
    <#
    .SYNOPSIS
        Возвращает все команды MatterMost с поддержкой пагинации.
    #>
    $page    = 0
    $perPage = 200

    do {
        $batch = Invoke-MMRequest -Endpoint "teams?page=$page&per_page=$perPage"
        $batch
        $page++
    } while ($batch.Count -eq $perPage)
}
