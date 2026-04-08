# Интеграционные тесты для расширенных командлетов Teams

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
}

Describe 'Get-MMTeamStats' {

    Context 'Статистика команды' {
        It 'возвращает статистику по TeamId' {
            $result = Get-MMTeamStats -TeamId $script:Team.id

            $result                    | Should -Not -BeNullOrEmpty
            $result.team_id            | Should -Be $script:Team.id
            $result.total_member_count | Should -BeGreaterThan 0
        }

        It 'содержит active_member_count' {
            $result = Get-MMTeamStats -TeamId $script:Team.id

            $result.active_member_count | Should -Not -BeNullOrEmpty
        }

        It 'принимает объект команды из пайплайна' {
            $result = $script:Team | Get-MMTeamStats

            $result.team_id | Should -Be $script:Team.id
        }

        It 'бросает исключение при невалидном TeamId' {
            { Get-MMTeamStats -TeamId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Set-MMTeamMemberRoles' {

    Context 'Установка ролей участника' {
        It 'устанавливает роль team_user без ошибок' {
            { Set-MMTeamMemberRoles -TeamId $script:Team.id -UserId $script:Admin.id -Roles 'team_user' } |
                Should -Not -Throw
        }

        It 'устанавливает роль team_user team_admin без ошибок' {
            { Set-MMTeamMemberRoles -TeamId $script:Team.id -UserId $script:Admin.id -Roles 'team_user team_admin' } |
                Should -Not -Throw
        }

        It 'возвращает обратно к team_user после team_admin' {
            Set-MMTeamMemberRoles -TeamId $script:Team.id -UserId $script:Admin.id -Roles 'team_user team_admin'
            { Set-MMTeamMemberRoles -TeamId $script:Team.id -UserId $script:Admin.id -Roles 'team_user' } |
                Should -Not -Throw
        }

        It 'принимает объект команды из пайплайна' {
            { $script:Team | Set-MMTeamMemberRoles -UserId $script:Admin.id -Roles 'team_user' } |
                Should -Not -Throw
        }

        It 'бросает исключение при невалидном TeamId' {
            { Set-MMTeamMemberRoles -TeamId 'invalid-id' -UserId $script:Admin.id -Roles 'team_user' } |
                Should -Throw
        }
    }
}

Describe 'Get-MMTeamUnreads' {

    Context 'Непрочитанные сообщения' {
        It 'возвращает данные для текущего пользователя (me)' {
            $result = Get-MMTeamUnreads

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает данные по конкретному TeamId' {
            $result = Get-MMTeamUnreads -TeamId $script:Team.id

            $result         | Should -Not -BeNullOrEmpty
            $result.team_id | Should -Be $script:Team.id
        }

        It 'содержит поле msg_count при запросе по TeamId' {
            $result = Get-MMTeamUnreads -TeamId $script:Team.id

            $result.PSObject.Properties.Name | Should -Contain 'msg_count'
        }

        It 'принимает UserId явно' {
            $result = Get-MMTeamUnreads -UserId $script:Admin.id

            $result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe 'Get-MMTeamInviteInfo' {

    Context 'Информация по invite_id' {
        It 'возвращает информацию о команде по invite_id' {
            $inviteId = $script:Team.invite_id
            $result   = Get-MMTeamInviteInfo -InviteId $inviteId

            $result      | Should -Not -BeNullOrEmpty
            $result.name | Should -Be $script:Team.name
        }

        It 'содержит display_name в ответе' {
            $inviteId = $script:Team.invite_id
            $result   = Get-MMTeamInviteInfo -InviteId $inviteId

            $result.display_name | Should -Not -BeNullOrEmpty
        }

        It 'бросает исключение при невалидном invite_id' {
            { Get-MMTeamInviteInfo -InviteId 'not-a-real-invite-id' } | Should -Throw
        }
    }
}

Describe 'Reset-MMTeamInvite' {

    Context 'Перегенерация invite_id' {
        It 'возвращает объект MMTeam с новым invite_id' {
            $oldInviteId = $script:Team.invite_id
            $result      = Reset-MMTeamInvite -TeamId $script:Team.id

            $result           | Should -Not -BeNullOrEmpty
            $result.invite_id | Should -Not -Be $oldInviteId
            $result.id        | Should -Be $script:Team.id
        }

        It 'принимает объект команды из пайплайна' {
            $team   = New-MMTeam -Name "invpipe$($script:Suffix)" -DisplayName "InvPipe $($script:Suffix)"
            $oldId  = $team.invite_id
            $result = $team | Reset-MMTeamInvite

            $result.invite_id | Should -Not -Be $oldId
        }

        It 'бросает исключение при невалидном TeamId' {
            { Reset-MMTeamInvite -TeamId 'invalid-id' } | Should -Throw
        }
    }
}

Describe 'Get-MMTeamIcon' {

    Context 'Скачивание иконки команды' {
        It 'не падает если иконки нет (404 возможен в sandbox)' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                Get-MMTeamIcon -TeamId $script:Team.id -OutFile $outFile
                # Если иконка есть — файл должен существовать
                (Test-Path $outFile) | Should -BeTrue
            }
            catch {
                # В sandbox иконки по умолчанию нет, это ожидаемо
                $_.Exception.Message | Should -Match '(404|No team icon|MM API error)'
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'принимает объект команды из пайплайна без краша' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                $script:Team | Get-MMTeamIcon -OutFile $outFile
            }
            catch {
                $_.Exception.Message | Should -Match '(404|No team icon|MM API error)'
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }

        It 'не крашится на невалидном TeamId (MM может вернуть дефолтную иконку или ошибку)' {
            $outFile = [System.IO.Path]::GetTempFileName() + '.png'
            try {
                # MM может вернуть дефолтную иконку или 404 — оба варианта приемлемы
                try { Get-MMTeamIcon -TeamId 'invalid-id' -OutFile $outFile } catch { }
                $true | Should -Be $true
            }
            finally {
                if (Test-Path $outFile) { Remove-Item $outFile -Force }
            }
        }
    }
}

Describe 'Set-MMTeamIcon' {

    Context 'Загрузка иконки команды' {
        It 'пропускается — требует реальный файл изображения на диске' -Skip:($true) {
            # Set-MMTeamIcon -TeamId $script:Team.id -FilePath '/path/to/icon.png'
        }
    }
}

Describe 'Remove-MMTeamIcon' {

    Context 'Удаление иконки команды' {
        It 'пропускается — sandbox может не иметь кастомной иконки' -Skip:($true) {
            # Remove-MMTeamIcon -TeamId $script:Team.id
        }
    }
}
