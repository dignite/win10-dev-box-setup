function Run {
    Write-Host "Please enter the following:"
    Write-Host ""
    Read-HostAndSaveToEnv -Description "Git user name (eg. John Doe)" -EnvironmentKey WIN10_DEV_BOX_GIT_USER_NAME
    Read-HostAndSaveToEnv -Description "Git email (eg. john.doe@example.com)" -EnvironmentKey WIN10_DEV_BOX_GIT_EMAIL
    Read-HostAndSaveToEnv -Description "Wireguard config path (eg. C:\wg0.conf)" -EnvironmentKey WIN10_DEV_BOX_WIREGUARD_CONFIG_PATH
    if(!(Test-Path "$([Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_WIREGUARD_CONFIG_PATH", "User"))")) {
        throw "Wireguard config path does not point to a file that exists!"
    }
    Read-HostAndSaveToEnv -Description "Gitlab base url (eg. http://gitlab.example.com)" -EnvironmentKey WIN10_DEV_BOX_GITLAB_BASE_URL
    Read-HostAndSaveToEnv -Description "Gitlab api token with 'api' access (eg. qyfymyD3syW_KqVPXhMH)" -EnvironmentKey WIN10_DEV_BOX_GITLAB_TOKEN
    #Read-HostAndSaveToEnv -Description "Gitlab group to clone (eg. 12)" -EnvironmentKey WIN10_DEV_BOX_GITLAB_GROUP_ID
    Write-Host "Done! Do you want to launch a One Click install of SetupDeveloperMachine.ps1 i Microsoft Edge? [y/N]" -ForegroundColor green
    Write-Host "> " -NoNewline
    $LaunchOneClickInstall = Read-Host
    if ($LaunchOneClickInstall -eq "y") {
        start msedge "http://boxstarter.org/package/url?https://raw.githubusercontent.com/dignite/win10-dev-box-setup/master/SetupDeveloperMachine.ps1"
    }
}

function Read-HostAndSaveToEnv($Description, $EnvironmentKey) {
    $CurrentValue = [Environment]::GetEnvironmentVariable($EnvironmentKey, "User")
    Write-Host $Description -ForegroundColor green
    if ($CurrentValue) {
        Write-Host "Simply press ENTER to preserve current value (" -NoNewline
        Write-Host $CurrentValue  -NoNewline -ForegroundColor blue
        Write-Host ")"
    }
    Write-Host "> " -NoNewline
    $NewValue = Read-Host
    if ($NewValue -ne "") {
        [Environment]::SetEnvironmentVariable($EnvironmentKey, $NewValue, "User")
    }
    Write-Host ""
}

Run