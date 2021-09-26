function Run {
    Write-Host "Please enter the following:"
    Write-Host ""
    Read-HostAndSaveToEnv -Description "Git user name" -EnvironmentKey WIN10_DEV_BOX_GIT_USER_NAME
    Read-HostAndSaveToEnv -Description "Git email" -EnvironmentKey WIN10_DEV_BOX_GIT_EMAIL
}

function Read-HostAndSaveToEnv($Description, $EnvironmentKey) {
    Write-Host $Description
    $Value = Read-Host
    [Environment]::SetEnvironmentVariable($EnvironmentKey, $Value, "User")
}

Run