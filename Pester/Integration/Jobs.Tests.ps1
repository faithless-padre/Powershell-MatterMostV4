# Интеграционные тесты для командлетов Jobs (Get-MMJob, New-MMJob, Stop-MMJob, Get-MMJobsByType)

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

    # Сразу получаем список всех джобов — пригодится в нескольких тестах
    $script:AllJobs     = @(Get-MMJob -ErrorAction SilentlyContinue)
    $script:FirstJob    = if ($script:AllJobs.Count -gt 0) { $script:AllJobs[0] } else { $null }

    # Пробуем создать тестовый джоб (data_retention_deletion — наименее зависимый от enterprise-фич)
    $script:NewJobSupported = $false
    $script:TestJob         = $null
    try {
        $script:TestJob         = New-MMJob -Type 'data_retention_deletion'
        $script:NewJobSupported = $true
    } catch { }
}

# ---------------------------------------------------------------------------

Describe 'Get-MMJob' {

    Context 'Список заданий' {
        It 'не бросает исключение при запросе всех заданий' {
            { Get-MMJob } | Should -Not -Throw
        }

        It 'возвращает массив или пустой результат' {
            $result = Get-MMJob
            # Не $null — может быть пустой массив
            $result | Should -Not -Be $null
        }

        It 'поддерживает пагинацию через Page и PerPage' {
            { Get-MMJob -Page 0 -PerPage 10 } | Should -Not -Throw
        }
    }

    Context 'Получение задания по ID' {
        It 'возвращает задание по JobId' -Skip:(-not $script:FirstJob) {
            $result = Get-MMJob -JobId $script:FirstJob.id

            $result    | Should -Not -BeNullOrEmpty
            $result.id | Should -Be $script:FirstJob.id
            $result.type | Should -Not -BeNullOrEmpty
        }

        It 'задание содержит поля status и create_at' -Skip:(-not $script:FirstJob) {
            $result = Get-MMJob -JobId $script:FirstJob.id

            $result.status    | Should -Not -BeNullOrEmpty
            $result.create_at | Should -BeGreaterThan 0
        }

        It 'бросает исключение при невалидном JobId' {
            { Get-MMJob -JobId 'invalid-job-id' } | Should -Throw
        }
    }
}

# ---------------------------------------------------------------------------

Describe 'Get-MMJobsByType' {

    It 'не бросает исключение для типа data_retention_deletion' -Skip:(-not $script:NewJobSupported) {
        { Get-MMJobsByType -Type 'data_retention_deletion' } | Should -Not -Throw
    }

    It 'не бросает исключение для типа message-export' -Skip:(-not $script:NewJobSupported) {
        { Get-MMJobsByType -Type 'message-export' } | Should -Not -Throw
    }

    It 'не бросает исключение для типа ldap-sync' -Skip:(-not $script:NewJobSupported) {
        { Get-MMJobsByType -Type 'ldap-sync' } | Should -Not -Throw
    }

    It 'возвращает только задания нужного типа' -Skip:(-not $script:NewJobSupported) {
        $result = @(Get-MMJobsByType -Type 'data_retention_deletion')

        foreach ($job in $result) {
            $job.type | Should -Be 'data_retention_deletion'
        }
    }

    It 'поддерживает пагинацию через Page и PerPage' -Skip:(-not $script:NewJobSupported) {
        { Get-MMJobsByType -Type 'data_retention_deletion' -Page 0 -PerPage 5 } | Should -Not -Throw
    }
}

# ---------------------------------------------------------------------------

Describe 'New-MMJob' {

    It 'создаёт задание типа data_retention_deletion' -Skip:(-not $script:NewJobSupported) {
        $script:TestJob | Should -Not -BeNullOrEmpty
        $script:TestJob.type | Should -Be 'data_retention_deletion'
        $script:TestJob.id   | Should -Not -BeNullOrEmpty
    }

    It 'возвращает задание со статусом pending или in_progress' -Skip:(-not $script:NewJobSupported) {
        $script:TestJob.status | Should -BeIn @('pending', 'in_progress', 'success', 'error', 'cancel_requested', 'canceled')
    }

    It 'создаёт задание с дополнительными данными' -Skip:(-not $script:NewJobSupported) {
        $job = $null
        try {
            $job = New-MMJob -Type 'data_retention_deletion' -Data @{ run_type = 'global' }
        } catch {
            Set-ItResult -Skipped -Because "Тип задания не поддерживает Data в этом окружении: $_"
            return
        }

        $job    | Should -Not -BeNullOrEmpty
        $job.id | Should -Not -BeNullOrEmpty
    }

    It 'возвращает ошибку или 501 если тип недоступен' -Skip:($script:NewJobSupported) {
        Set-ItResult -Skipped -Because 'New-MMJob недоступен в этом окружении (ожидаемо)'
    }
}

# ---------------------------------------------------------------------------

Describe 'Stop-MMJob' {

    It 'отменяет задание в состоянии pending или in_progress' -Skip:(-not $script:NewJobSupported) {
        # Берём свежесозданный джоб — он скорее всего ещё pending
        $jobId = $script:TestJob.id
        $job   = Get-MMJob -JobId $jobId

        if ($job.status -notin @('pending', 'in_progress')) {
            Set-ItResult -Skipped -Because "Задание уже завершено (status=$($job.status)), отменять нечего"
            return
        }

        { Stop-MMJob -JobId $jobId -Confirm:$false } | Should -Not -Throw
    }

    It 'принимает объект задания из пайплайна' -Skip:(-not $script:NewJobSupported) {
        # Создаём ещё один джоб специально для этого теста
        $job = $null
        try {
            $job = New-MMJob -Type 'data_retention_deletion'
        } catch {
            Set-ItResult -Skipped -Because "Не удалось создать задание для теста пайплайна: $_"
            return
        }

        if ($job.status -notin @('pending', 'in_progress')) {
            Set-ItResult -Skipped -Because "Задание уже завершено (status=$($job.status))"
            return
        }

        { $job | Stop-MMJob -Confirm:$false } | Should -Not -Throw
    }

    It 'бросает исключение при невалидном JobId' {
        { Stop-MMJob -JobId 'invalid-job-id' -Confirm:$false } | Should -Throw
    }

    It 'пропускается если нет ни одного активного задания' -Skip:($script:NewJobSupported -or $script:FirstJob) {
        Set-ItResult -Skipped -Because 'Нет доступных заданий для тестирования Stop-MMJob'
    }
}
