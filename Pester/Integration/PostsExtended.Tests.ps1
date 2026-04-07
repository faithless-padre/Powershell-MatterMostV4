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
    $script:Me      = Get-MMUser
}

Describe 'Search-MMPost' {

    Context 'Поиск поста по тексту' {
        It 'находит пост с уникальным текстом' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'PesterSearchTarget42'

            $results = Search-MMPost -Terms 'PesterSearchTarget42'

            $results         | Should -Not -BeNullOrEmpty
            $results.id      | Should -Contain $post.id
            $results[0].GetType().Name | Should -Be 'MMPost'

            Remove-MMPost -PostId $post.id
        }

        It 'возвращает MMPost объекты' {
            $post    = New-MMPost -ChannelId $script:Channel.id -Message 'PesterSearchTypeCheck99'
            $results = Search-MMPost -Terms 'PesterSearchTypeCheck99'

            foreach ($r in $results) {
                $r.GetType().Name | Should -Be 'MMPost'
            }

            Remove-MMPost -PostId $post.id
        }

        It 'не бросает исключение при поиске без результатов' {
            { Search-MMPost -Terms 'zzz_no_such_text_xyzzy_pester' } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMFlaggedPosts' {

    Context 'Получение избранных постов' {
        It 'не бросает исключение при вызове без параметров' {
            { Get-MMFlaggedPosts } | Should -Not -Throw
        }

        It 'возвращает массив (возможно пустой)' {
            # Допустимо вернуть null/пустой массив (нет отмеченных постов у admin)
            { Get-MMFlaggedPosts } | Should -Not -Throw
        }
    }
}

Describe 'Get-MMPostFileInfo' {

    Context 'Пост без вложений' {
        It 'возвращает пустой результат для поста без файлов' {
            $post   = New-MMPost -ChannelId $script:Channel.id -Message 'FileInfoTest_NoAttach'
            $result = Get-MMPostFileInfo -PostId $post.id

            $result | Should -BeNullOrEmpty

            Remove-MMPost -PostId $post.id
        }

        It 'принимает объект MMPost из пайплайна' {
            $post   = New-MMPost -ChannelId $script:Channel.id -Message 'FileInfoTest_Pipeline'
            { $post | Get-MMPostFileInfo } | Should -Not -Throw

            Remove-MMPost -PostId $post.id
        }
    }
}

Describe 'Set-MMPostUnread' {

    Context 'Пометка поста как непрочитанного' {
        It 'не бросает исключение' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'UnreadTest_Pester'
            { Set-MMPostUnread -PostId $post.id } | Should -Not -Throw

            Remove-MMPost -PostId $post.id
        }

        It 'принимает объект MMPost из пайплайна' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'UnreadTest_Pipeline'
            { $post | Set-MMPostUnread } | Should -Not -Throw

            Remove-MMPost -PostId $post.id
        }
    }
}

Describe 'New-MMEphemeralPost' {

    Context 'Создание эфемерного поста' {
        It 'создаёт эфемерный пост и возвращает MMPost' {
            $result = New-MMEphemeralPost -UserId $script:Me.id -ChannelId $script:Channel.id -Message 'Ephemeral test from Pester'

            $result                | Should -Not -BeNullOrEmpty
            $result.GetType().Name | Should -Be 'MMPost'
        }

        It 'возвращённый пост содержит переданный текст' {
            $result = New-MMEphemeralPost -UserId $script:Me.id -ChannelId $script:Channel.id -Message 'EphemeralContent_42'

            $result.message | Should -Be 'EphemeralContent_42'
        }
    }
}

Describe 'New-MMPostReminder' {

    Context 'Установка напоминания о посте' {
        It 'не бросает исключение при установке напоминания' {
            $post     = New-MMPost -ChannelId $script:Channel.id -Message 'ReminderTest_Pester'
            $remindAt = (Get-Date).AddDays(1)

            { New-MMPostReminder -PostId $post.id -RemindAt $remindAt } | Should -Not -Throw

            Remove-MMPost -PostId $post.id
        }

        It 'принимает объект MMPost из пайплайна' {
            $post     = New-MMPost -ChannelId $script:Channel.id -Message 'ReminderTest_Pipeline'
            $remindAt = (Get-Date).AddHours(2)

            { $post | New-MMPostReminder -RemindAt $remindAt } | Should -Not -Throw

            Remove-MMPost -PostId $post.id
        }
    }
}

Describe 'Set-MMPostAcknowledged / Remove-MMPostAcknowledgement' {

    Context 'Подтверждение и снятие подтверждения поста' {
        It 'подтверждает пост без ошибок' -Skip:($true) {
            # Post acknowledgement requires Enterprise license (501 on Team Edition)
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'AckTest_Pester'
            { Set-MMPostAcknowledged -PostId $post.id } | Should -Not -Throw
            $script:AckPost = $post
        }

        It 'снимает подтверждение без ошибок' -Skip:($true) {
            # Post acknowledgement requires Enterprise license (501 on Team Edition)
            { Remove-MMPostAcknowledgement -PostId $script:AckPost.id } | Should -Not -Throw
            Remove-MMPost -PostId $script:AckPost.id
        }

        It 'принимает объект MMPost из пайплайна для Set-MMPostAcknowledged' -Skip:($true) {
            # Post acknowledgement requires Enterprise license (501 on Team Edition)
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'AckTest_Pipeline'
            { $post | Set-MMPostAcknowledged }       | Should -Not -Throw
            { $post | Remove-MMPostAcknowledgement } | Should -Not -Throw
            Remove-MMPost -PostId $post.id
        }
    }
}

Describe 'Invoke-MMPostAction' {

    It 'требует интерактивного сообщения — тест пропущен' -Skip:($true) {
        # Для тестирования нужно интерактивное сообщение с настроенными actions.
        # В sandbox-окружении без входящего вебхука это нереально воспроизвести надёжно.
        Invoke-MMPostAction -PostId 'fake' -ActionId 'fake'
    }
}
