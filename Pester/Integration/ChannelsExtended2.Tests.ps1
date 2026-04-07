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

    $script:Channel = Get-MMChannel -Name 'town-square'
    $script:Team    = Get-MMTeam -Name $config.TestTeamName
    $script:Me      = Get-MMUser -Me
}

AfterAll {
    if ($script:SidebarCategory) {
        try { Remove-MMSidebarCategory -CategoryId $script:SidebarCategory.id -Confirm:$false } catch { }
    }
}

Describe 'Search-MMChannel' {

    Context 'Поиск по строке' {
        It 'возвращает каналы, содержащие строку поиска' {
            $result = Search-MMChannel -Term 'town'

            $result               | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMChannel'
            $result[0].id         | Should -Not -BeNullOrEmpty
        }

        It 'возвращает объекты типа MMChannel' {
            $result = Search-MMChannel -Term 'town'

            $result | ForEach-Object { $_.GetType().Name | Should -Be 'MMChannel' }
        }
    }
}

Describe 'Get-MMChannelStats' {

    Context 'Статистика канала' {
        It 'возвращает статистику канала с member_count > 0' {
            $result = Get-MMChannelStats -ChannelId $script:Channel.id

            $result              | Should -Not -BeNullOrEmpty
            $result.channel_id   | Should -Be $script:Channel.id
            $result.member_count | Should -BeGreaterThan 0
        }

        It 'принимает объект канала из пайплайна' {
            $result = $script:Channel | Get-MMChannelStats

            $result.channel_id | Should -Be $script:Channel.id
        }
    }
}

Describe 'Get-MMChannelPinnedPosts' {

    Context 'Закреплённые посты канала' {
        BeforeAll {
            $script:PinTestPost = New-MMPost -ChannelId $script:Channel.id -Message 'Pester pin test post'
            Add-MMPostPin -PostId $script:PinTestPost.id
        }

        AfterAll {
            if ($script:PinTestPost) {
                try { Remove-MMPostPin -PostId $script:PinTestPost.id } catch { }
                try { Remove-MMPost   -PostId $script:PinTestPost.id } catch { }
            }
        }

        It 'возвращает закреплённые посты канала' {
            $result = Get-MMChannelPinnedPosts -ChannelId $script:Channel.id

            $result | Should -Not -BeNullOrEmpty
        }

        It 'содержит только что закреплённый пост' {
            $result = Get-MMChannelPinnedPosts -ChannelId $script:Channel.id
            $ids    = $result | Select-Object -ExpandProperty id

            $ids | Should -Contain $script:PinTestPost.id
        }

        It 'возвращает объекты типа MMPost' {
            $result = Get-MMChannelPinnedPosts -ChannelId $script:Channel.id

            $result | ForEach-Object { $_.GetType().Name | Should -Be 'MMPost' }
        }

        It 'принимает объект канала из пайплайна' {
            $result = $script:Channel | Get-MMChannelPinnedPosts

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Set-MMChannelViewed' {

    Context 'Отметка канала как просмотренного' {
        It 'выполняется без ошибок' {
            { Set-MMChannelViewed -ChannelId $script:Channel.id } | Should -Not -Throw
        }

        It 'принимает объект канала из пайплайна' {
            { $script:Channel | Set-MMChannelViewed } | Should -Not -Throw
        }
    }
}

Describe 'Move-MMChannel' {

    Context 'Перемещение канала' {
        It 'тест пропущен — деструктивная операция, требует отдельного окружения' -Skip:($true) {
            # Move-MMChannel меняет принадлежность канала другой команде.
            # Тест намеренно пропущен, чтобы не ломать тестовое окружение.
        }
    }
}

Describe 'Set-MMChannelMemberRoles' {

    Context 'Изменение ролей участника канала' {
        It 'устанавливает роль channel_user без ошибок' {
            { Set-MMChannelMemberRoles -ChannelId $script:Channel.id -UserId $script:Me.id -Roles 'channel_user' } |
                Should -Not -Throw
        }
    }
}

Describe 'Set-MMChannelMemberNotifyProps' {

    Context 'Изменение настроек уведомлений' {
        It 'устанавливает Desktop notify prop без ошибок' {
            { Set-MMChannelMemberNotifyProps -ChannelId $script:Channel.id -UserId $script:Me.id -Desktop 'mention' } |
                Should -Not -Throw
        }

        It 'устанавливает несколько notify props без ошибок' {
            { Set-MMChannelMemberNotifyProps -ChannelId $script:Channel.id -UserId $script:Me.id -Desktop 'default' -Push 'mention' -MarkUnread 'mention' } |
                Should -Not -Throw
        }
    }
}

Describe 'Get-MMSidebarCategories' {

    Context 'Список категорий сайдбара' {
        It 'возвращает категории без параметров' {
            $result = Get-MMSidebarCategories

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает объекты типа MMSidebarCategory' {
            $result = Get-MMSidebarCategories

            $result | ForEach-Object { $_.GetType().Name | Should -Be 'MMSidebarCategory' }
        }

        It 'каждая категория содержит поле id' {
            $result = Get-MMSidebarCategories

            $result | ForEach-Object { $_.id | Should -Not -BeNullOrEmpty }
        }
    }
}

Describe 'New-MMSidebarCategory' {

    Context 'Создание категории' {
        It 'создаёт кастомную категорию с заданным DisplayName' {
            $result = New-MMSidebarCategory -DisplayName 'Pester Test Category'

            $result              | Should -Not -BeNullOrEmpty
            $result.display_name | Should -Be 'Pester Test Category'
            $result.id           | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'MMSidebarCategory'

            $script:SidebarCategory = $result
        }
    }
}

Describe 'Get-MMSidebarCategory' {

    Context 'Получение категории по ID' {
        It 'возвращает категорию по CategoryId' {
            $result = Get-MMSidebarCategory -CategoryId $script:SidebarCategory.id

            $result              | Should -Not -BeNullOrEmpty
            $result.id           | Should -Be $script:SidebarCategory.id
            $result.display_name | Should -Be 'Pester Test Category'
            $result.GetType().Name | Should -Be 'MMSidebarCategory'
        }

        It 'принимает объект MMSidebarCategory из пайплайна' {
            $result = $script:SidebarCategory | Get-MMSidebarCategory

            $result.id | Should -Be $script:SidebarCategory.id
        }
    }
}

Describe 'Set-MMSidebarCategory' {

    Context 'Обновление категории' {
        It 'обновляет DisplayName категории' {
            $result = Set-MMSidebarCategory -CategoryId $script:SidebarCategory.id -DisplayName 'Updated Category'

            $result              | Should -Not -BeNullOrEmpty
            $result.display_name | Should -Be 'Updated Category'
            $result.GetType().Name | Should -Be 'MMSidebarCategory'

            $script:SidebarCategory = $result
        }
    }
}

Describe 'Get-MMSidebarCategoryOrder' {

    Context 'Порядок категорий' {
        It 'возвращает массив строк с ID категорий' {
            $result = Get-MMSidebarCategoryOrder

            $result       | Should -Not -BeNullOrEmpty
            $result.Count | Should -BeGreaterThan 0
            $result[0]    | Should -BeOfType [string]
        }
    }
}

Describe 'Set-MMSidebarCategoryOrder' {

    Context 'Установка порядка категорий' {
        It 'устанавливает тот же порядок обратно без ошибок' {
            $order = Get-MMSidebarCategoryOrder
            { Set-MMSidebarCategoryOrder -CategoryIds $order } | Should -Not -Throw
        }
    }
}

Describe 'Remove-MMSidebarCategory' {

    Context 'Удаление категории' {
        It 'удаляет тестовую категорию без ошибок' {
            { Remove-MMSidebarCategory -CategoryId $script:SidebarCategory.id -Confirm:$false } |
                Should -Not -Throw

            $script:SidebarCategory = $null
        }
    }
}
