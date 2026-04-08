# Интеграционные тесты для расширенных командлетов Files

BeforeAll {
    $fileConfig = Get-Content (Join-Path $PSScriptRoot 'testconfig.json') | ConvertFrom-Json

    $config = @{
        Url           = if ($env:MM_URL)            { $env:MM_URL }            else { $fileConfig.Url }
        AdminUsername = if ($env:MM_ADMIN_USERNAME) { $env:MM_ADMIN_USERNAME } else { $fileConfig.AdminUsername }
        AdminPassword = if ($env:MM_ADMIN_PASSWORD) { $env:MM_ADMIN_PASSWORD } else { $fileConfig.AdminPassword }
        TestUsername  = if ($env:MM_TEST_USERNAME)  { $env:MM_TEST_USERNAME }  else { $fileConfig.TestUsername }
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

    $channel = Get-MMChannel -Name 'town-square'

    # Загружаем текстовый файл (для Search-MMFile)
    $tmpTxt = [System.IO.Path]::GetTempFileName() + '.txt'
    'test content' | Set-Content $tmpTxt
    $script:UploadedFile = Send-MMFile -ChannelId $channel.id -FilePath $tmpTxt
    Remove-Item $tmpTxt -Force

    # Загружаем минимальный 1×1 PNG (для thumbnail/preview тестов)
    $pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='
    $pngBytes  = [System.Convert]::FromBase64String($pngBase64)
    $tmpPng    = [System.IO.Path]::GetTempFileName() + '.png'
    [System.IO.File]::WriteAllBytes($tmpPng, $pngBytes)
    $script:UploadedImage = Send-MMFile -ChannelId $channel.id -FilePath $tmpPng
    Remove-Item $tmpPng -Force
}

Describe 'Get-MMFileThumbnail' {

    Context 'Скачивание миниатюры файла' {
        It 'скачивает миниатюру и сохраняет в файл' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = Get-MMFileThumbnail -FileId $script:UploadedImage.id -OutFile $outFile

                $result           | Should -Not -BeNullOrEmpty
                (Test-Path $outFile) | Should -BeTrue
                (Get-Item $outFile).Length | Should -BeGreaterThan 0
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'принимает объект файла из пайплайна' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = $script:UploadedImage | Get-MMFileThumbnail -OutFile $outFile

                (Test-Path $outFile) | Should -BeTrue
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'возвращает объект FileInfo' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = Get-MMFileThumbnail -FileId $script:UploadedImage.id -OutFile $outFile

                $result | Should -BeOfType [System.IO.FileInfo]
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'бросает исключение при невалидном FileId' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                { Get-MMFileThumbnail -FileId 'invalid-file-id' -OutFile $outFile } | Should -Throw
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }
    }
}

Describe 'Get-MMFilePreview' {

    Context 'Скачивание превью файла' {
        It 'скачивает превью и сохраняет в файл' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = Get-MMFilePreview -FileId $script:UploadedImage.id -OutFile $outFile

                $result              | Should -Not -BeNullOrEmpty
                (Test-Path $outFile) | Should -BeTrue
                (Get-Item $outFile).Length | Should -BeGreaterThan 0
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'принимает объект файла из пайплайна' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = $script:UploadedImage | Get-MMFilePreview -OutFile $outFile

                (Test-Path $outFile) | Should -BeTrue
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'возвращает объект FileInfo' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $result = Get-MMFilePreview -FileId $script:UploadedImage.id -OutFile $outFile

                $result | Should -BeOfType [System.IO.FileInfo]
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'бросает исключение при невалидном FileId' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                { Get-MMFilePreview -FileId 'invalid-file-id' -OutFile $outFile } | Should -Throw
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }
    }
}

Describe 'Search-MMFile' {

    # Поиск файлов требует включённого Elasticsearch — в sandbox недоступен (возвращает 404)
    Context 'Поиск файлов' {
        It 'не бросает исключение при поиске по термину' -Skip:($true) {
            { Search-MMFile -Terms 'test' } | Should -Not -Throw
        }

        It 'возвращает массив (или пустой результат) без краша' -Skip:($true) {
            $result = Search-MMFile -Terms 'test'
            $result | Should -Not -Throw
        }

        It 'не бросает исключение при явном TeamId' -Skip:($true) {
            { Search-MMFile -Terms 'test' -TeamId $script:Team.id } | Should -Not -Throw
        }

        It 'не бросает исключение с флагом IsOrSearch' -Skip:($true) {
            { Search-MMFile -Terms 'test content' -IsOrSearch } | Should -Not -Throw
        }

        It 'не бросает исключение с флагом IncludeDeletedChannels' -Skip:($true) {
            { Search-MMFile -Terms 'test' -IncludeDeletedChannels } | Should -Not -Throw
        }

        It 'не бросает исключение с параметрами пагинации' -Skip:($true) {
            { Search-MMFile -Terms 'test' -Page 0 -PerPage 10 } | Should -Not -Throw
        }

        It 'бросает исключение при невалидном TeamId' -Skip:($true) {
            { Search-MMFile -Terms 'test' -TeamId 'invalid-id' } | Should -Throw
        }
    }
}
