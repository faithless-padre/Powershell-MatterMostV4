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
}

Describe 'New-MMPost' {

    Context 'Создание поста по ChannelId' {
        It 'создаёт пост и возвращает MMPost объект' {
            $result = New-MMPost -ChannelId $script:Channel.id -Message 'Pester test post'

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Not -BeNullOrEmpty
            $result.message        | Should -Be 'Pester test post'
            $result.channel_id     | Should -Be $script:Channel.id
            $result.GetType().Name | Should -Be 'MMPost'

            $script:RootPost = $result
        }
    }

    Context 'Создание поста по ChannelName' {
        It 'создаёт пост по имени канала' {
            $result = New-MMPost -ChannelName 'town-square' -Message 'Post by channel name'

            $result.channel_id | Should -Be $script:Channel.id
            $result.message    | Should -Be 'Post by channel name'
        }
    }

    Context 'Создание поста через пайплайн канала' {
        It 'принимает объект MMChannel из пайплайна' {
            $result = $script:Channel | New-MMPost -Message 'Post via pipeline'

            $result.channel_id | Should -Be $script:Channel.id
        }
    }

    Context 'Создание треда' {
        It 'создаёт ответ в тред через -RootId' {
            $result = New-MMPost -ChannelId $script:Channel.id -Message 'Thread reply' -RootId $script:RootPost.id

            $result.root_id | Should -Be $script:RootPost.id
            $result.message | Should -Be 'Thread reply'

            $script:ThreadReply = $result
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { New-MMPost -ChannelId 'invalid-id' -Message 'test' } | Should -Throw
        }

        It 'бросает исключение при несуществующем ChannelName' {
            { New-MMPost -ChannelName 'nonexistent-channel-xyz' -Message 'test' } | Should -Throw
        }
    }
}

Describe 'Get-MMPost' {

    Context 'Получение по ID' {
        It 'возвращает пост по ID' {
            $result = Get-MMPost -PostId $script:RootPost.id

            $result.id      | Should -Be $script:RootPost.id
            $result.message | Should -Be 'Pester test post'
            $result.GetType().Name | Should -Be 'MMPost'
        }

        It 'принимает объект MMPost из пайплайна' {
            $result = $script:RootPost | Get-MMPost

            $result.id | Should -Be $script:RootPost.id
        }
    }

    Context 'Получение по списку ID' {
        It 'возвращает несколько постов по массиву ID' {
            $result = Get-MMPost -PostIds @($script:RootPost.id, $script:ThreadReply.id)

            $result        | Should -Not -BeNullOrEmpty
            $result.Count  | Should -Be 2
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном PostId' {
            { Get-MMPost -PostId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMPost' {

    Context 'Редактирование поста' {
        It 'обновляет текст поста' {
            $post   = New-MMPost -ChannelId $script:Channel.id -Message 'Original message'
            $result = Set-MMPost -PostId $post.id -Message 'Updated message'

            $result.id      | Should -Be $post.id
            $result.message | Should -Be 'Updated message'
            $result.GetType().Name | Should -Be 'MMPost'
        }

        It 'принимает объект MMPost из пайплайна' {
            $post   = New-MMPost -ChannelId $script:Channel.id -Message 'Pipeline original'
            $result = $post | Set-MMPost -Message 'Pipeline updated'

            $result.message | Should -Be 'Pipeline updated'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном PostId' {
            { Set-MMPost -PostId 'invalid-id' -Message 'test' } | Should -Throw
        }
    }
}

Describe 'Remove-MMPost' {

    Context 'Удаление поста' {
        It 'удаляет пост без ошибок' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'Post to delete'
            { Remove-MMPost -PostId $post.id } | Should -Not -Throw
        }

        It 'принимает объект MMPost из пайплайна' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'Pipeline delete'
            { $post | Remove-MMPost } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном PostId' {
            { Remove-MMPost -PostId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Get-MMChannelPosts' {

    Context 'Список постов канала' {
        It 'возвращает посты канала' {
            $result = Get-MMChannelPosts -ChannelId $script:Channel.id -PerPage 10

            $result               | Should -Not -BeNullOrEmpty
            $result[0].channel_id | Should -Be $script:Channel.id
            $result[0].GetType().Name | Should -Be 'MMPost'
        }

        It 'принимает объект MMChannel из пайплайна' {
            $result = $script:Channel | Get-MMChannelPosts -PerPage 5

            $result | Should -Not -BeNullOrEmpty
        }

        It 'поддерживает пагинацию' {
            $page0 = Get-MMChannelPosts -ChannelId $script:Channel.id -Page 0 -PerPage 5
            $page1 = Get-MMChannelPosts -ChannelId $script:Channel.id -Page 1 -PerPage 5

            # Посты на разных страницах должны отличаться
            $page0[0].id | Should -Not -Be $page1[0].id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном ChannelId' {
            { Get-MMChannelPosts -ChannelId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Get-MMPostThread' {

    Context 'Получение треда' {
        It 'возвращает корневой пост и ответы треда' {
            $result = Get-MMPostThread -PostId $script:RootPost.id

            $result | Should -Not -BeNullOrEmpty
            $ids    = $result | Select-Object -ExpandProperty id
            $ids    | Should -Contain $script:RootPost.id
            $ids    | Should -Contain $script:ThreadReply.id
        }

        It 'принимает объект MMPost из пайплайна' {
            $result = $script:RootPost | Get-MMPostThread

            $result | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном PostId' {
            { Get-MMPostThread -PostId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Add-MMPostPin / Remove-MMPostPin' {

    Context 'Закрепление и открепление поста' {
        It 'закрепляет пост без ошибок' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'Pin test post'
            { Add-MMPostPin -PostId $post.id } | Should -Not -Throw

            $script:PinnedPost = $post
        }

        It 'открепляет пост без ошибок' {
            { Remove-MMPostPin -PostId $script:PinnedPost.id } | Should -Not -Throw
        }

        It 'принимает объект MMPost из пайплайна' {
            $post = New-MMPost -ChannelId $script:Channel.id -Message 'Pin pipeline test'
            { $post | Add-MMPostPin }    | Should -Not -Throw
            { $post | Remove-MMPostPin } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'Add-MMPostPin бросает исключение при невалидном PostId' {
            { Add-MMPostPin -PostId 'invalid-id' } | Should -Throw
        }

        It 'Remove-MMPostPin бросает исключение при невалидном PostId' {
            { Remove-MMPostPin -PostId 'invalid-id' } | Should -Throw
        }
    }
}
