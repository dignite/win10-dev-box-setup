function Run {
    InstallPrerequisites
    ConfigureEnvironment
    InstallWindowsSubsystemForLinux
    InstallPrograms
    ConfigureDevelopmentTools
    CleanUp
    RunWindowsUpdate
    AddBoxstarterDoneRestorePoint
    OpenManualInstructions
}

function InstallPrerequisites {
    if (Check-Command -cmdname 'choco') {
        Write-Host "Choco is already installed, skip installation."
    }
    else {
        Write-Host "Installing Chocolatey first..."
        Write-Host "------------------------------------"
        Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        Write-Host "Installed Chocolatey" -ForegroundColor Green
    }
    if (Check-Command -cmdname 'Install-BoxstarterPackage') {
        Write-Host "Boxstarter is already installed, skip installation."
    }
    else {
        Write-Host "Installing Boxstarter..."
        Write-Host "------------------------------------"
        . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force
        Write-Host "Installed Boxstarter" -ForegroundColor Green
    }
    if (Check-Command -cmdname 'scoop') {
        Write-Host "scoop is already installed, skip installation."
    }
    else {
        Write-Host "Installing scoop..."
        Write-Host "------------------------------------"
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
        Write-Host "Installed scoop" -ForegroundColor Green
    }

    refreshenv
}

function ConfigureEnvironment {
    Enable-ComputerRestore -Drive "C:\"
    vssadmin list shadowstorage
    vssadmin resize shadowstorage /on=C: /for=C: /maxsize=10%
    Set-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -Value 5
    if  (!((Get-ComputerRestorePoint).Description -Like "Clean Install")) {
        Checkpoint-Computer -Description "Clean Install"
    }

    Write-Host "Setting up power options"
    Powercfg /Change monitor-timeout-ac 20
    Powercfg /Change standby-timeout-ac 0
    powercfg -setacvalueindex scheme_current sub_buttons pbuttonaction 0
    Write-Host "Completed power options" -Foreground green

    # Show hidden files, Show protected OS files, Show file extensions
    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowTaskViewButton -Value 0 -Type DWord -Force
    Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name ShowCortanaButton -Value 0 -Type DWord -Force
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search -Name SearchBoxTaskbarMode -Value 0 -Type DWord -Force

    # Remove all $AppNames String array from taskbar Pin location
    $ComObj = (New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}')
    $AppNames = "Microsoft Edge|stor|mai|support"
    #use the match to limit the apps removed from start tiles
    $ComObjItem = $ComObj.Items() | ?{$_.Name -match $AppNames}
    foreach ($Obj in $ComObjItem) {
        Write-Host "$("Checking " + $Obj.name)" -ForegroundColor Cyan
        foreach ($Verb in $Obj.Verbs()) {
            Write-Host "$("Verb: " + $Verb.name)" -ForegroundColor white
            if (($Verb.name -match 'Un.*pin from Start')) {
                Write-Host "$("Ok " + $Obj.name + " contains " + $Verb.name)" -ForegroundColor Red
                try {
                    $Verb.DoIt()
                } catch {}
            }
            if (($Verb.name -match 'Un.*pin from tas&kbar') -And ($Obj.name -match $AppNames)) {
                Write-Host "$("Ok " + $Obj.name + " contains " + $Verb.name)" -ForegroundColor Red
                try {
                    $Verb.DoIt()
                } catch {}
            }
        }
    }

    $WallpaperImagePath = "$([Environment]::GetFolderPath("MyDocuments"))/wallpaper.jpg"
    (new-object net.webclient).DownloadFile("https://unsplash.com/photos/eMBdLhYY468/download?force=true", $WallpaperImagePath)
    Set-ItemProperty -path "HKCU:Control Panel\Desktop" -name WallPaper -value $WallpaperImagePath
    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name TileWallpaper -value "0"
    $SpanWallpaper = "22";
    Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name WallpaperStyle -value $SpanWallpaper -Force
    RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True

}

function InstallWindowsSubsystemForLinux {
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform
    refreshenv
    wsl --set-default-version 2
    wsl --update
    if (!((wsl --list --all) -Like "*Ubuntu*")) {
        wsl --install --distribution Ubuntu
    }
}

function InstallPrograms {
    Write-Host "Installing programs using choco or scoop"
    choco install poshgit -y
    choco install divvy -y
    choco install microsoft-edge -y
    choco install googlechrome -y
    choco install firefox -y
    choco install obs-studio -y
    choco install vscode -y
    choco install nvm -y
    choco install lastpass -y
    choco install slack -y
    choco install greenshot -y
    choco install azure-data-studio -y
    choco install microsoft-windows-terminal -y
    choco install firacode -y
    choco install dotnetcore -y
    choco install jetbrains-rider -y
    choco install lastpass -y
    choco install ssms -y
    choco install docker-desktop -y
    choco install dotnetcore-sdk -y
    scoop install yarn
    scoop install sudo
    scoop install pwsh
    Write-Host "Installed programs" -Foreground green
}


function ConfigureDevelopmentTools {
    Write-Host "Installing VS Code extensions"
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension esbenp.prettier-vscode
    code --install-extension formulahendry.auto-rename-tag
    code --install-extension hbenl.vscode-test-explorer
    code --install-extension hbenl.vscode-test-explorer-liveshare
    code --install-extension kavod-io.vscode-jest-test-adapter
    code --install-extension ms-vsliveshare.vsliveshare
    code --install-extension msjsdiag.debugger-for-chrome
    code --install-extension PKief.material-icon-theme
    code --install-extension runningcoder.react-snippets
    code --install-extension schmas.jump-to-tests
    code --install-extension sandcastle.vscode-open
    Write-Host "Installed VS Code Extensions" -Foreground green

    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name z -RequiredVersion 1.1.10 -AllowClobber
    Install-Module psreadline -Force

    Add-ToPowerShellProfile -Find "*Set-PSReadLineOption*" -Content @("
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    ")

    git config --global push.default current
    git config --global core.editor "code --wait"
    git config --global diff.tool vscode
    git config --global difftool.vscode.cmd 'code --wait $MERGED'
    git config --global merge.tool vscode
    git config --global mergetool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
    git config --global mergetool.keepBackup false
    git config --global alias.co "checkout"
    git config --global alias.oops "commit --amend --no-edit"
    git config --global alias.a "add --patch"
    git config --global alias.please "push --force-with-lease"
    git config --global alias.navigate "!git add . && git commit -m 'WIP-mob' --allow-empty --no-verify && git push -u --no-verify"
    git config --global alias.drive "!git pull --rebase && git log -1 --stat && git reset HEAD^ && git push --force-with-lease"
    git config --global pull.rebase true
    git config --global alias.r "!git fetch; git rebase origin/master -i --autosquash"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    git config --global alias.mr "push -u -o merge_request.create -o merge_request.remove_source_branch"


    mkdir C:\dev
}

function CleanUp {
    Write-Host "Cleaning desktop"
    Remove-Item C:\Users\*\Desktop\*lnk
    Remove-Item C:\Users\*\Desktop\desktop.ini
    Write-Host "Desktop cleaned"
}

function RunWindowsUpdate {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-Module -Name PSWindowsUpdate -Repository PSGallery
    Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -AddServiceFlag 7
    Get-WindowsUpdate
    Install-WindowsUpdate
}

function AddBoxstarterDoneRestorePoint {
    if  (!((Get-ComputerRestorePoint).Description -Like "Boxstarter done")) {
        Checkpoint-Computer -Description "Boxstarter done"
    }
}

function OpenManualInstructions {
    $ManualInstructionsFilePath = "$([Environment]::GetFolderPath("Desktop"))/ManualSteps.txt";
    "Please configure personal information.
        git config --global user.email ""<email>""
        git config --global user.name ""<name>""

    Manual installs
        MicSwitch https://github.com/iXab3r/MicSwitch/releases
        LogiCapture https://www.logitech.com/en-us/product/capture
        choco install clipx -y

    Configure ClipX
        1. Right click tray icon and open settings
        2. Check ""Run ClipX on Startup""
        3. Remember the last 256 entries
        4. Delete hotkeys ""Navigate"" and ""Google Search""

    Configure VSCode
    1. Turn on Settings Sync (Ctrl+P ""Turn On"")
    2. Log in with Github
    3. ""Replace Local""
    
    Add saved Powershell_profile.ps1
    Add saved Windows Terminal settings.json" | Add-Content $ManualInstructionsFilePath -Encoding UTF8
    notepad.exe $ManualInstructionsFilePath
}

#### -> HELPER FUNCTIONS ####

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function Add-ToPowerShellProfile($Find, $Content) {
    if (!( Test-Path $Profile )) { 
        New-Item $Profile -Type File -Force
    } else  {
        $CurrentProfileContent = Get-Content $Profile
    }

    if (!($CurrentProfileContent -Like $Find)) {
        $Content | Add-Content $Profile -Encoding UTF8
    }
}

#### <- HELPER FUNCTIONS ####

Run