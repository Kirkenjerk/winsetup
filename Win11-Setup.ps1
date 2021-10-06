#Runs powershell window as admin if not already elevated.
##################################
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}
##################################


# Creates log directory if not already present
##################################
$LogFolder = "C:\Temp\Windows-11-Setup"
If (Test-Path $LogFolder) {
    Write-Output "$LogFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$LogFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$LogFolder" -ItemType Directory
    Write-Output "The folder $LogFolder was successfully created."
}

Start-Transcript -OutputDirectory "$LogFolder"
##################################


# Sets execution policy to bypass in order to run scripts and installs Chocolatey.
##################################
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
##################################


# Configures software for computer
##################################
$applist = Get-Content -Path .\apps.txt
$programlist = Get-Content -Path .\program.txt
$tweaks = @()
$PSCommandArgs = @()

# Installs applications from app.txt
foreach ($app in $applist) {
    choco install $app -y
}

# Debloat Windows 11 by removing preinstalled applications
foreach ($program in $programlist) {
    Get-AppxPackage $program | Remove-AppxPackage
}

# Enables and installs Ubuntu Linux Subsystem for Windows
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
# You can change which linux distro you wish to install by changing the distro name below. It is currently set to Ubuntu.
wsl --install -d Ubuntu
Start-Sleep 2
Write-Output "If the WSL install fails, then install the msi from this link: https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
Start-Sleep 5
##################################