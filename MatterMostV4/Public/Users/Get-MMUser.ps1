# Получение пользователя MatterMost по ID, username, фильтру или текущей сессии

function Get-MMUser {
    <#
    .SYNOPSIS
        Возвращает пользователя MatterMost по ID, username, фильтру или текущей сессии.
    .EXAMPLE
        Get-MMUser -All
    .EXAMPLE
        Get-MMUser -Me
    .EXAMPLE
        Get-MMUser -Username "testuser"
    .EXAMPLE
        Get-MMUser -UserId "abc123"
    .EXAMPLE
        Get-MMUser -Filter {username -eq 'admin'}
    .EXAMPLE
        Get-MMUser -Filter {username -like 'adm*'}
    .EXAMPLE
        Get-MMUser -Filter {username -ne 'admin'}
    .EXAMPLE
        $user | Get-MMUser
    #>
    [CmdletBinding(DefaultParameterSetName = 'Me')]
    param(
        [Parameter(ParameterSetName = 'All')]
        [switch]$All,

        [Parameter(ParameterSetName = 'Me')]
        [switch]$Me,

        [Parameter(Mandatory, ParameterSetName = 'ById', ValueFromPipelineByPropertyName)]
        [Alias('id')]
        [string]$UserId,

        [Parameter(Mandatory, ParameterSetName = 'ByUsername', Position = 0)]
        [string]$Username,

        [Parameter(Mandatory, ParameterSetName = 'ByEmail')]
        [string]$Email,

        [Parameter(Mandatory, ParameterSetName = 'Filter')]
        [scriptblock]$Filter
    )

    process {
        $typeName = 'MatterMost.User'
        switch ($PSCmdlet.ParameterSetName) {
            'All'        { Get-MMUserList                                        | Add-MMTypeName -TypeName $typeName }
            'Me'         { Invoke-MMRequest -Endpoint 'users/me'                 | Add-MMTypeName -TypeName $typeName }
            'ById'       { Invoke-MMRequest -Endpoint "users/$UserId"            | Add-MMTypeName -TypeName $typeName }
            'ByUsername' { Invoke-MMRequest -Endpoint "users/username/$Username" | Add-MMTypeName -TypeName $typeName }
            'ByEmail'    { Invoke-MMRequest -Endpoint "users/email/$Email"       | Add-MMTypeName -TypeName $typeName }
            'Filter'     { Invoke-MMUserFilter -Filter $Filter                   | Add-MMTypeName -TypeName $typeName }
        }
    }
}

function Invoke-MMUserFilter {
    <#
    .SYNOPSIS
        Парсит ScriptBlock фильтра и возвращает пользователей MatterMost по условию.
    #>
    param([scriptblock]$Filter)

    $filterStr = $Filter.ToString().Trim()

    if ($filterStr -notmatch "^(\w+)\s+(-eq|-like|-ne)\s+['""]([^'""]+)['""]$") {
        throw "Invalid filter syntax. Supported: {field -eq 'value'}, {field -like 'value'}, {field -ne 'value'}"
    }

    $field    = $Matches[1]
    $operator = $Matches[2]
    $value    = $Matches[3]

    # Быстрый путь: username -eq через прямой endpoint
    if ($field -eq 'username' -and $operator -eq '-eq') {
        return Invoke-MMRequest -Endpoint "users/username/$value"
    }

    # Для -ne нужны все пользователи
    if ($operator -eq '-ne') {
        $users = Get-MMUserList
        return $users | Where-Object { $_.$field -ne $value }
    }

    # Для -eq и -like используем search + клиентская фильтрация
    $searchResults = Invoke-MMRequest -Endpoint 'users/search' -Method POST -Body @{ term = $value; limit = 100 }

    switch ($operator) {
        '-eq'   { $searchResults | Where-Object { $_.$field -eq $value } }
        '-like' { $searchResults | Where-Object { $_.$field -like $value } }
    }
}
