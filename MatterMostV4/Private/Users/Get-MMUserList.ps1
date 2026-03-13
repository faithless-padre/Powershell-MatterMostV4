# Внутренний хелпер для получения всех пользователей с пагинацией

function Get-MMUserList {
    <#
    .SYNOPSIS
        Возвращает всех пользователей MatterMost с поддержкой пагинации.
    #>
    $page    = 0
    $perPage = 200

    do {
        $batch = Invoke-MMRequest -Endpoint "users?page=$page&per_page=$perPage"
        $batch
        $page++
    } while ($batch.Count -eq $perPage)
}
