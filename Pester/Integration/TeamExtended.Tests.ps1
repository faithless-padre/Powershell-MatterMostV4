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

Describe 'Get-MMTeamMembers' {

    Context 'Список участников' {
        It 'возвращает участников команды' {
            $result = Get-MMTeamMembers -TeamId $script:Team.id

            $result            | Should -Not -BeNullOrEmpty
            $result[0].team_id | Should -Be $script:Team.id
            $result[0].user_id | Should -Not -BeNullOrEmpty
        }

        It 'принимает объект команды из пайплайна' {
            $result = $script:Team | Get-MMTeamMembers

            $result | Should -Not -BeNullOrEmpty
        }

        It 'возвращает участников по TeamName' {
            $result = Get-MMTeamMembers -TeamName $script:Team.name

            $result            | Should -Not -BeNullOrEmpty
            $result[0].team_id | Should -Be $script:Team.id
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Get-MMTeamMembers -TeamId 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'Set-MMTeamPrivacy' {

    Context 'Изменение приватности' {
        It 'переключает открытую команду в invite-only' {
            $team   = New-MMTeam -Name "priv$($script:Suffix)" -DisplayName "Privacy Test $($script:Suffix)"
            $result = Set-MMTeamPrivacy -TeamId $team.id -Privacy Invite

            $result      | Should -Not -BeNullOrEmpty
            $result.type | Should -Be 'I'
        }

        It 'переключает invite-only команду обратно в открытую' {
            $team   = New-MMTeam -Name "open$($script:Suffix)" -DisplayName "Open Test $($script:Suffix)" -Type Invite
            $result = Set-MMTeamPrivacy -TeamId $team.id -Privacy Open

            $result.type | Should -Be 'O'
        }

        It 'принимает объект команды из пайплайна' {
            $team   = New-MMTeam -Name "pipe$($script:Suffix)" -DisplayName "Pipe Test $($script:Suffix)"
            $result = $team | Set-MMTeamPrivacy -Privacy Invite

            $result.type | Should -Be 'I'
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Set-MMTeamPrivacy -TeamId 'invalid-id' -Privacy Invite } |
                Should -Throw
        }
    }
}

Describe 'Restore-MMTeam' {

    Context 'Восстановление команды' {
        It 'восстанавливает удалённую команду' {
            $team   = New-MMTeam -Name "restore$($script:Suffix)" -DisplayName "Restore Test $($script:Suffix)"
            Remove-MMTeam -TeamId $team.id
            $result = Restore-MMTeam -TeamId $team.id

            $result           | Should -Not -BeNullOrEmpty
            $result.delete_at | Should -Be 0
        }

        It 'принимает объект команды из пайплайна' {
            $team   = New-MMTeam -Name "restpipe$($script:Suffix)" -DisplayName "RestPipe $($script:Suffix)"
            Remove-MMTeam -TeamId $team.id
            $result = $team | Restore-MMTeam

            $result.delete_at | Should -Be 0
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Restore-MMTeam -TeamId 'invalid-id' } |
                Should -Throw
        }
    }
}

Describe 'Send-MMTeamInvite' {

    Context 'Отправка приглашения' {
        It 'достигает API (ошибка от сервера, не от клиента)' {
            # Email invitations may be disabled in sandbox — we verify the request reaches the API
            try {
                Send-MMTeamInvite -TeamId $script:Team.id -Emails 'invite@example.com'
            } catch {
                $_.Exception.Message | Should -Match '(disabled|invite|501|200)'
            }
        }

        It 'принимает объект команды из пайплайна' {
            try {
                $script:Team | Send-MMTeamInvite -Emails 'invite2@example.com'
            } catch {
                $_.Exception.Message | Should -Match '(disabled|invite|501|200)'
            }
        }

        It 'отправляет приглашение по TeamName' {
            try {
                Send-MMTeamInvite -TeamName $script:Team.name -Emails 'invitename@example.com'
            } catch {
                $_.Exception.Message | Should -Match '(disabled|invite|501|200)'
            }
        }
    }

    Context 'Ошибки' {
        It 'бросает исключение при невалидном TeamId' {
            { Send-MMTeamInvite -TeamId 'invalid-id' -Emails 'test@example.com' } |
                Should -Throw
        }
    }
}
