function Run {
    Write-Host "Please enter the following:"
    Write-Host ""
    Read-HostAndSaveToEnv -Description "Git user name (eg. John Doe)" -EnvironmentKey WIN10_DEV_BOX_GIT_USER_NAME
    Read-HostAndSaveToEnv -Description "Git email (eg. john.doe@example.com)" -EnvironmentKey WIN10_DEV_BOX_GIT_EMAIL
    Read-HostAndSaveToEnv -Description "Wireguard config path (eg. C:\wg0.conf)" -EnvironmentKey WIN10_DEV_BOX_WIREGUARD_CONFIG_PATH
    if(!(Test-Path "$([Environment]::GetEnvironmentVariable("WIN10_DEV_BOX_WIREGUARD_CONFIG_PATH", "User"))")) {
        throw "Wireguard config path does not point to a file that exists!"
    }
}

function Read-HostAndSaveToEnv($Description, $EnvironmentKey) {
    Write-Host $Description
    $Value = Read-Host
    [Environment]::SetEnvironmentVariable($EnvironmentKey, $Value, "User")
}

Run