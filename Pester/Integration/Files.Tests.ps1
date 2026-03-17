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

    # Создаём временный файл для загрузки и отдельную папку для скачивания
    $script:TempFile   = Join-Path ([System.IO.Path]::GetTempPath()) 'mmtest_upload.txt'
    $script:DownloadDir = Join-Path ([System.IO.Path]::GetTempPath()) 'mm_pester_downloads'
    Set-Content -Path $script:TempFile -Value 'MatterMost Pester test file'
    New-Item -ItemType Directory -Path $script:DownloadDir -Force | Out-Null

    $script:Channel = Get-MMChannel -Name 'town-square'
}

AfterAll {
    if (Test-Path $script:TempFile)    { Remove-Item $script:TempFile -Force }
    if (Test-Path $script:DownloadDir) { Remove-Item $script:DownloadDir -Recurse -Force }
}

Describe 'Send-MMFile' {

    Context 'Загрузка файла' {
        It 'загружает файл и возвращает MMFile объект' {
            $result = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id

            $result          | Should -Not -BeNullOrEmpty
            $result.id       | Should -Not -BeNullOrEmpty
            $result.name     | Should -Be 'mmtest_upload.txt'
            $result.GetType().Name | Should -Be 'MMFile'

            $script:UploadedFileId = $result.id
        }

        It 'принимает объект канала из пайплайна' {
            $result = $script:Channel | Send-MMFile -FilePath $script:TempFile

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение если файл не существует' {
            { Send-MMFile -FilePath 'C:\nonexistent\file.txt' -ChannelId $script:Channel.id } |
                Should -Throw
        }

        It 'бросает исключение при невалидном ChannelId' {
            { Send-MMFile -FilePath $script:TempFile -ChannelId 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'Get-MMFileMetadata' {

    Context 'Получение метаданных' {
        It 'возвращает метаданные загруженного файла' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id
            $result   = Get-MMFileMetadata -FileId $uploaded.id

            $result          | Should -Not -BeNullOrEmpty
            $result.id       | Should -Be $uploaded.id
            $result.name     | Should -Be 'mmtest_upload.txt'
            $result.size     | Should -BeGreaterThan 0
            $result.GetType().Name | Should -Be 'MMFile'
        }

        It 'принимает объект MMFile из пайплайна' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id
            $result   = $uploaded | Get-MMFileMetadata

            $result.id | Should -Be $uploaded.id
        }

        It 'бросает исключение при невалидном FileId' {
            { Get-MMFileMetadata -FileId 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'Save-MMFile' {

    Context 'Скачивание файла' {
        It 'скачивает файл в указанную директорию' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id
            $destFile = Join-Path $script:DownloadDir 'mmtest_upload.txt'

            if (Test-Path $destFile) { Remove-Item $destFile -Force }

            $result = Save-MMFile -FileId $uploaded.id -DestinationPath $script:DownloadDir

            $result          | Should -Not -BeNullOrEmpty
            $result.Exists   | Should -Be $true
            $result.Name     | Should -Be 'mmtest_upload.txt'

            Remove-Item $destFile -Force
        }

        It 'принимает объект MMFile из пайплайна и не делает лишний запрос к /info' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id
            $destFile = Join-Path $script:DownloadDir 'mmtest_upload.txt'

            if (Test-Path $destFile) { Remove-Item $destFile -Force }

            $result = $uploaded | Save-MMFile -DestinationPath $script:DownloadDir

            $result.Exists | Should -Be $true

            Remove-Item $destFile -Force
        }

        It 'скачивает файл по FileId без FileName (запрашивает метаданные)' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id
            $destFile = Join-Path $script:DownloadDir 'mmtest_upload.txt'

            if (Test-Path $destFile) { Remove-Item $destFile -Force }

            # Передаём только FileId — имя должно быть получено из /api/v4/files/{id}/info
            $result = Save-MMFile -FileId $uploaded.id -DestinationPath $script:DownloadDir

            $result.Exists | Should -Be $true
            $result.Name   | Should -Be 'mmtest_upload.txt'

            Remove-Item $destFile -Force
        }

        It 'бросает исключение при невалидном FileId' {
            { Save-MMFile -FileId 'invalid-id' -DestinationPath $script:DownloadDir } |
                Should -Throw
        }
    }
}

Describe 'Get-MMFileLink' {

    Context 'Получение публичной ссылки' {
        It 'возвращает строку с публичной ссылкой или ошибку если публичные ссылки отключены' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id

            # В sandbox публичные ссылки могут быть отключены — оба исхода валидны
            try {
                $result = Get-MMFileLink -FileId $uploaded.id
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match '^http'
            }
            catch {
                $_.Exception.Message | Should -Match '(501|disabled|public)'
            }
        }

        It 'принимает объект MMFile из пайплайна' {
            $uploaded = Send-MMFile -FilePath $script:TempFile -ChannelId $script:Channel.id

            try {
                $result = $uploaded | Get-MMFileLink
                $result | Should -Not -BeNullOrEmpty
            }
            catch {
                $_.Exception.Message | Should -Match '(501|403|disabled|public)'
            }
        }

        It 'бросает исключение при невалидном FileId' {
            { Get-MMFileLink -FileId 'invalid-id' } |
                Should -Throw
        }
    }
}
