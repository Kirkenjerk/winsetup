#########################
# Import custom functions
#########################

Import-Module .\functions.ps1

#########################
#Setup Script environment
#########################

#Runs powershell window as admin if not already elevated.

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# Creates log directory if not already present

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

#################################################################################
# Checks if Chocolatey is installed and if not installs it.
#################################################################################
$chocofolder = "C:\ProgramData\chocolatey"

if (Test-Path -Path $chocofolder){
    "Path Exists, no need to install chocolatey"
}
else {
    "Choco is not installed, will be installed now..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

##################################
# Configures software for computer
##################################
$applist = Get-Content -Path .\apps.txt
$programlist = Get-Content -Path .\program.txt

# Installs applications from app.txt
foreach ($app in $applist) {
    choco install $app -y
}

# Debloat Windows 11 by removing preinstalled applications
foreach ($program in $programlist) {
    Get-AppxPackage $program | Remove-AppxPackage
}

#################################################
# Configure various settings via custom functions
#################################################

Protect-Privacy
DisableCortana
Stop-EdgePDF
UninstallOneDrive
Remove3dObjects

#################################
# Installs Ubuntu Linux Subsystem
#################################
install-wsl