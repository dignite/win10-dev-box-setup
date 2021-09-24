#### -> HELPER FUNCTIONS ####

function Check-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

#### <- HELPER FUNCTIONS ####

#### -> PREREQUISITES ####

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

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
refreshenv

#### <- PREREQUISITES ####

######## -> ENVIRONMENT CONFIGURATION ########

Enable-ComputerRestore -Drive "C:\"
vssadmin list shadowstorage
vssadmin resize shadowstorage /on=C: /for=C: /maxsize=10%
Set-ItemProperty "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" -Name SystemRestorePointCreationFrequency -Value 5
Checkpoint-Computer -Description "Clean Install"

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
            $Verb.DoIt()
        }
        if (($Verb.name -match 'Un.*pin from tas&kbar') -And ($Obj.name -match $AppNames)) {
            Write-Host "$("Ok " + $Obj.name + " contains " + $Verb.name)" -ForegroundColor Red
            $Verb.DoIt()
        }
    }
}

######## <- ENVIRONMENT CONFIGURATION ########


######## -> WINDOWS UPDATE ########

Install-Module PSWindowsUpdate
Add-WUServiceManager -ServiceID 7971f918-a847-4430-9279-4a52d1efe18d -AddServiceFlag 7
Get-WindowsUpdate
Install-WindowsUpdate

Checkpoint-Computer -Description "Clean Install with Updates"

######## <- WINDOWS UPDATE ########

######## -> COMMON TOOLS CONFIGURATION ########

Write-Host "Installing common tools using choco"

$Apps = @(
    #Browsers
    "microsoft-edge",
    "googlechrome",
    "firefox",
    
    #Communications
    
    #Editing
    
    # Media players and production

    #"kdenlive", # Supports standalone 
    "obs-studio",
    
    # Network & Debugging
    "postman",

    #office

    #Scriptings
    
    #Utils
    "greenshot"
)

foreach ($app in $Apps) {
    cinst $app -y
} 
Write-Host "Installed common tools" -Foreground green

######## <- COMMON TOOLS CONFIGURATION ########

######## -> DEV TOOLS CONFIGURATION ########

Write-Host "Installing dev tools using choco"
$devTools = @(
    #Editors
    "vscode",
    #Version control    
    "git",
    #.Net
    "dotnetcore-sdk",
    #NodeJS
    "nodejs-lts",
    #Database
    "ssms"
)
foreach ($devTool in $devTools) {
    cinst $devTool -y
}

$vsCodeExtensions = @(
    "jebbs.plantuml",
    "evilz.vscode-reveal",
    "streetsidesoftware.code-spell-checker",
    "ms-azuretools.vscode-docker"
)
Write-Host "Installing VS Code extensions"
$vsCodeExtensions | ForEach-Object { code --install-extension $_}
Write-Host "Installed VS Code Extensions" -Foreground green
Write-Host "Installed dev tools" -Foreground green

######## <- DEV TOOLS CONFIGURATION ########

#### -> PERSONALIZE ####

Write-Host "Done! Please configure personal information."
Write-Host "    git config --global user.email ""<email>""" -Foreground green
Write-Host "    git config --global user.name ""<name>""" -Foreground green

#### <- PERSONALIZE ####
