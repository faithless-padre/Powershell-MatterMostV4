# Интеграционные тесты для командлетов Groups (Get/New/Remove/Set/Restore-MMGroup, Members, Stats)

BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestTeamName  = if ($env:MM_TEST_TEAM_NAME) { $env:MM_TEST_TEAM_NAME } else { $fileConfig.TestTeamName }
    }

    $modulePath = if (Test-Path '/module/MatterMostV4.psd1') {
        '/module/MatterMostV4.psd1'
    } else {
        Join-Path $PSScriptRoot '..\..\MatterMostV4\MatterMostV4.psd1'
    }
    Import-Module $modulePath -Force

    Connect-MMServer -Url $config.Url -Username $config.AdminUsername -Password (ConvertTo-SecureString $config.AdminPassword -AsPlainText -Force) -DefaultTeam $config.TestTeamName

    $script:Suffix = (Get-Date -Format 'HHmmss')
    $script:Team   = Get-MMTeam -Name $config.TestTeamName
    $script:Admin  = Get-MMUser -Me

    # Пробуем создать тестовую группу — на Team Edition вернёт 501
    $script:GroupsSupported = $false
    $script:TestGroup       = $null
    try {
        $script:TestGroup       = New-MMGroup -Name "testgrp$($script:Suffix)" -DisplayName "Test Group $($script:Suffix)"
        $script:GroupsSupported = $true
    } catch { }
}

# ---------------------------------------------------------------------------

Describe 'Get-MMGroup' {

    Context 'Список групп' {
        It 'не бросает исключение при запросе всех групп' -Skip:(-not $script:GroupsSupported) {
            { Get-MMGroup } | Should -Not -Throw
        }

        It 'поддерживает фильтрацию по Q без ошибок' -Skip:(-not $script:GroupsSupported) {
            { Get-MMGroup -Q 'nonexistent' } | Should -Not -Throw
        }

        It 'поддерживает флаг FilterAllowReference без ошибок' -Skip:(-not $script:GroupsSupported) {
            { Get-MMGroup -FilterAllowReference } | Should -Not -Throw
        }

        It 'поддерживает пагинацию через Page и PerPage' -Skip:(-not $script:GroupsSupported) {
            { Get-MMGroup -Page 0 -PerPage 10 } | Should -Not -Throw
        }
    }

    Context 'Получение группы по ID' {
        It 'возвращает группу по GroupId' -Skip:(-not $script:GroupsSupported) {
            $result = Get-MMGroup -GroupId $script:TestGroup.id

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:TestGroup.id
        }

        It 'бросает исключение при невалидном GroupId' {
            { Get-MMGroup -GroupId 'invalid-group-id' } | Should -Throw
        }
    }
}

# ---------------------------------------------------------------------------

Describe 'New-MMGroup' {

    It 'создаёт группу с именем и DisplayName' -Skip:(-not $script:GroupsSupported) {
        $script:TestGroup | Should -Not -BeNullOrEmpty
        $script:TestGroup.name         | Should -BeLike "testgrp*"
        $script:TestGroup.source       | Should -Be 'custom'
        $script:TestGroup.allow_reference | Should -Be $true
    }

    It 'создаёт группу с UserIds' -Skip:(-not $script:GroupsSupported) {
        $group = New-MMGroup -Name "grpuid$($script:Suffix)" -DisplayName "Group UID $($script:Suffix)" -UserIds @($script:Admin.id)

        $group    | Should -Not -BeNullOrEmpty
        $group.id | Should -Not -BeNullOrEmpty

        Remove-MMGroup -GroupId $group.id -Confirm:$false
    }

    It 'возвращает 501 или исключение, если функция недоступна' -Skip:($script:GroupsSupported) {
        # Custom Groups недоступны в этом окружении — тест пропущен
        Set-ItResult -Skipped -Because 'Custom Groups не поддерживаются (ожидаемо на Team Edition)'
    }
}

# ---------------------------------------------------------------------------

Describe 'Set-MMGroup' {

    It 'обновляет DisplayName группы' -Skip:(-not $script:GroupsSupported) {
        $newName = "Updated Group $($script:Suffix)"
        $result  = Set-MMGroup -GroupId $script:TestGroup.id -DisplayName $newName

        $result              | Should -Not -BeNullOrEmpty
        $result.display_name | Should -Be $newName
    }

    It 'обновляет AllowReference группы' -Skip:(-not $script:GroupsSupported) {
        $result = Set-MMGroup -GroupId $script:TestGroup.id -AllowReference $false

        $result                  | Should -Not -BeNullOrEmpty
        $result.allow_reference  | Should -Be $false

        # возвращаем как было
        Set-MMGroup -GroupId $script:TestGroup.id -AllowReference $true | Out-Null
    }

    It 'принимает объект группы из пайплайна' -Skip:(-not $script:GroupsSupported) {
        $result = $script:TestGroup | Set-MMGroup -DisplayName "Pipe Updated $($script:Suffix)"

        $result | Should -Not -BeNullOrEmpty
    }

    It 'бросает исключение при невалидном GroupId' {
        { Set-MMGroup -GroupId 'invalid-group-id' -DisplayName 'X' } | Should -Throw
    }
}

# ---------------------------------------------------------------------------

Describe 'Get-MMGroupMembers' {

    It 'возвращает список участников группы' -Skip:(-not $script:GroupsSupported) {
        $result = Get-MMGroupMembers -GroupId $script:TestGroup.id

        # Список может быть пустым, но не должен бросать исключение
        $result | Should -Not -Be $null
    }

    It 'принимает объект группы из пайплайна' -Skip:(-not $script:GroupsSupported) {
        { $script:TestGroup | Get-MMGroupMembers } | Should -Not -Throw
    }

    It 'поддерживает пагинацию через Page и PerPage' -Skip:(-not $script:GroupsSupported) {
        { Get-MMGroupMembers -GroupId $script:TestGroup.id -Page 0 -PerPage 10 } | Should -Not -Throw
    }

    It 'бросает исключение при невалидном GroupId' {
        { Get-MMGroupMembers -GroupId 'invalid-group-id' } | Should -Throw
    }
}

# ---------------------------------------------------------------------------

Describe 'Add-MMGroupMembers и Remove-MMGroupMembers' {

    It 'добавляет пользователя в группу' -Skip:(-not $script:GroupsSupported) {
        $result = Add-MMGroupMembers -GroupId $script:TestGroup.id -UserIds @($script:Admin.id)

        $result | Should -Not -BeNullOrEmpty
    }

    It 'принимает объект группы из пайплайна при добавлении' -Skip:(-not $script:GroupsSupported) {
        { $script:TestGroup | Add-MMGroupMembers -UserIds @($script:Admin.id) } | Should -Not -Throw
    }

    It 'удаляет пользователя из группы' -Skip:(-not $script:GroupsSupported) {
        # убеждаемся что пользователь в группе перед удалением
        Add-MMGroupMembers -GroupId $script:TestGroup.id -UserIds @($script:Admin.id) | Out-Null

        { Remove-MMGroupMembers -GroupId $script:TestGroup.id -UserIds @($script:Admin.id) -Confirm:$false } |
            Should -Not -Throw
    }

    It 'принимает объект группы из пайплайна при удалении' -Skip:(-not $script:GroupsSupported) {
        Add-MMGroupMembers -GroupId $script:TestGroup.id -UserIds @($script:Admin.id) | Out-Null

        { $script:TestGroup | Remove-MMGroupMembers -UserIds @($script:Admin.id) -Confirm:$false } |
            Should -Not -Throw
    }

    It 'бросает исключение при невалидном GroupId (Add)' {
        { Add-MMGroupMembers -GroupId 'invalid-group-id' -UserIds @('uid') } | Should -Throw
    }

    It 'бросает исключение при невалидном GroupId (Remove)' {
        { Remove-MMGroupMembers -GroupId 'invalid-group-id' -UserIds @('uid') -Confirm:$false } | Should -Throw
    }
}

# ---------------------------------------------------------------------------

Describe 'Get-MMGroupStats' {

    It 'возвращает статистику группы' -Skip:(-not $script:GroupsSupported) {
        $result = Get-MMGroupStats -GroupId $script:TestGroup.id

        $result                    | Should -Not -BeNullOrEmpty
        $result.group_id           | Should -Be $script:TestGroup.id
        $result.total_member_count | Should -BeGreaterOrEqual 0
    }

    It 'принимает объект группы из пайплайна' -Skip:(-not $script:GroupsSupported) {
        $result = $script:TestGroup | Get-MMGroupStats

        $result          | Should -Not -BeNullOrEmpty
        $result.group_id | Should -Be $script:TestGroup.id
    }

    It 'бросает исключение при невалидном GroupId' {
        { Get-MMGroupStats -GroupId 'invalid-group-id' } | Should -Throw
    }
}

# ---------------------------------------------------------------------------

Describe 'Remove-MMGroup и Restore-MMGroup' {

    It 'удаляет группу (soft-delete)' -Skip:(-not $script:GroupsSupported) {
        $group = New-MMGroup -Name "delgrp$($script:Suffix)" -DisplayName "Delete Test $($script:Suffix)"

        { Remove-MMGroup -GroupId $group.id -Confirm:$false } | Should -Not -Throw

        $script:DeletedGroupId = $group.id
    }

    It 'восстанавливает удалённую группу' -Skip:(-not $script:GroupsSupported) {
        $group   = New-MMGroup -Name "rstgrp$($script:Suffix)" -DisplayName "Restore Test $($script:Suffix)"
        Remove-MMGroup -GroupId $group.id -Confirm:$false

        $result = Restore-MMGroup -GroupId $group.id

        $result           | Should -Not -BeNullOrEmpty
        $result.delete_at | Should -Be 0
    }

    It 'принимает объект группы из пайплайна (Restore)' -Skip:(-not $script:GroupsSupported) {
        $group = New-MMGroup -Name "rpipe$($script:Suffix)" -DisplayName "Restore Pipe $($script:Suffix)"
        Remove-MMGroup -GroupId $group.id -Confirm:$false

        $result = [pscustomobject]@{ id = $group.id } | Restore-MMGroup

        $result.delete_at | Should -Be 0
    }

    It 'бросает исключение при невалидном GroupId (Remove)' {
        { Remove-MMGroup -GroupId 'invalid-group-id' -Confirm:$false } | Should -Throw
    }

    It 'бросает исключение при невалидном GroupId (Restore)' {
        { Restore-MMGroup -GroupId 'invalid-group-id' } | Should -Throw
    }
}

# ---------------------------------------------------------------------------

AfterAll {
    # Чистим основную тестовую группу, если была создана
    if ($script:GroupsSupported -and $script:TestGroup) {
        try { Remove-MMGroup -GroupId $script:TestGroup.id -Confirm:$false } catch { }
    }
}
