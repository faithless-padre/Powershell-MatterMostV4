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

    $script:AdminUser = Get-MMUser -Username $config.AdminUsername

    # Минимальный валидный PNG (1x1 пиксель, прозрачный)
    $pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
    $script:TempImage = Join-Path ([System.IO.Path]::GetTempPath()) 'pester_emoji.png'
    [System.IO.File]::WriteAllBytes($script:TempImage, [System.Convert]::FromBase64String($pngBase64))

    $script:DownloadDir = Join-Path ([System.IO.Path]::GetTempPath()) 'pester_emoji_dl'
    New-Item -ItemType Directory -Path $script:DownloadDir -Force | Out-Null
}

AfterAll {
    if (Test-Path $script:TempImage)   { Remove-Item $script:TempImage -Force }
    if (Test-Path $script:DownloadDir) { Remove-Item $script:DownloadDir -Recurse -Force }
}

Describe 'New-MMEmoji / Get-MMEmoji' {

    Context 'Создание кастомного эмодзи' {
        It 'создаёт эмодзи и возвращает MMEmoji объект' {
            $name   = "pester$(Get-Date -Format 'HHmmss')"
            $result = New-MMEmoji -Name $name -ImagePath $script:TempImage

            $result                | Should -Not -BeNullOrEmpty
            $result.id             | Should -Not -BeNullOrEmpty
            $result.name           | Should -Be $name
            $result.GetType().Name | Should -Be 'MMEmoji'

            $script:Emoji     = $result
            $script:EmojiName = $name
        }

        It 'создаёт эмодзи с явным CreatorId' {
            $name   = "pestercid$(Get-Date -Format 'HHmmss')"
            $result = New-MMEmoji -Name $name -ImagePath $script:TempImage -CreatorId $script:AdminUser.id

            $result.name           | Should -Be $name
            $result.creator_id     | Should -Be $script:AdminUser.id
            $result.GetType().Name | Should -Be 'MMEmoji'

            Remove-MMEmoji -EmojiId $result.id
        }
    }

    Context 'Получение эмодзи' {
        It 'возвращает эмодзи по ID' {
            $result = Get-MMEmoji -EmojiId $script:Emoji.id

            $result.id             | Should -Be $script:Emoji.id
            $result.name           | Should -Be $script:EmojiName
            $result.GetType().Name | Should -Be 'MMEmoji'
        }

        It 'возвращает эмодзи по имени' {
            $result = Get-MMEmoji -Name $script:EmojiName

            $result.id   | Should -Be $script:Emoji.id
            $result.name | Should -Be $script:EmojiName
        }

        It 'возвращает список всех эмодзи' {
            $result = Get-MMEmoji

            $result | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMEmoji'
        }

        It 'возвращает список отсортированный по имени' {
            $result = Get-MMEmoji -Sort 'name'

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает batch эмодзи по именам' {
            $result = Get-MMEmoji -Names @($script:EmojiName)

            $result      | Should -Not -BeNullOrEmpty
            $ids = $result | Select-Object -ExpandProperty id
            $ids | Should -Contain $script:Emoji.id
        }
    }

    Context 'Ошибки Get-MMEmoji' {
        It 'бросает исключение при невалидном EmojiId' {
            { Get-MMEmoji -EmojiId 'invalid-emoji-id' } | Should -Throw
        }

        It 'бросает исключение при несуществующем имени' {
            { Get-MMEmoji -Name 'nonexistent_emoji_xyz_123' } | Should -Throw
        }
    }
}

Describe 'Find-MMEmoji' {

    Context 'Поиск эмодзи' {
        It 'находит эмодзи по части имени' {
            $result = Find-MMEmoji -Term 'pester'

            $result | Should -Not -BeNullOrEmpty
            $result[0].GetType().Name | Should -Be 'MMEmoji'
        }

        It 'поиск с PrefixOnly' {
            $result = Find-MMEmoji -Term 'pest' -PrefixOnly

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает autocomplete по части имени' {
            $result = Find-MMEmoji -Autocomplete 'pest'

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Save-MMEmojiImage' {

    Context 'Скачивание изображения' {
        It 'скачивает изображение эмодзи по ID' {
            $result = Save-MMEmojiImage -EmojiId $script:Emoji.id -DestinationPath $script:DownloadDir

            $result          | Should -Not -BeNullOrEmpty
            $result.Exists   | Should -Be $true
            $result.Length   | Should -BeGreaterThan 0
        }

        It 'принимает объект MMEmoji из пайплайна' {
            $result = $script:Emoji | Save-MMEmojiImage -DestinationPath $script:DownloadDir

            $result.Exists | Should -Be $true
        }

        It 'скачивает в текущую директорию если DestinationPath не указан' {
            Push-Location $script:DownloadDir
            try {
                $result = Save-MMEmojiImage -EmojiId $script:Emoji.id

                $result.Exists        | Should -Be $true
                $result.DirectoryName | Should -Be $script:DownloadDir
            } finally {
                Pop-Location
                # Cleanup файла созданного без имени (EmojiId.png)
                $byId = Join-Path $script:DownloadDir "$($script:Emoji.id).png"
                if (Test-Path $byId) { Remove-Item $byId -Force }
            }
        }

        It 'сохраняет по явному пути файла если DestinationPath не директория' {
            $destFile = Join-Path $script:DownloadDir 'explicit_output.png'
            if (Test-Path $destFile) { Remove-Item $destFile -Force }

            $result = Save-MMEmojiImage -EmojiId $script:Emoji.id -DestinationPath $destFile

            $result.Exists    | Should -Be $true
            $result.Name      | Should -Be 'explicit_output.png'

            Remove-Item $destFile -Force
        }

        It 'бросает исключение при невалидном EmojiId' {
            { Save-MMEmojiImage -EmojiId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Remove-MMEmoji' {

    Context 'Удаление эмодзи' {
        It 'удаляет эмодзи без ошибок' {
            { Remove-MMEmoji -EmojiId $script:Emoji.id } | Should -Not -Throw
        }

        It 'принимает объект MMEmoji из пайплайна' {
            $name  = "pesterrm$(Get-Date -Format 'HHmmss')"
            $emoji = New-MMEmoji -Name $name -ImagePath $script:TempImage
            { $emoji | Remove-MMEmoji } | Should -Not -Throw
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном EmojiId' {
            { Remove-MMEmoji -EmojiId 'invalid-id' } | Should -Throw
        }
    }
}
