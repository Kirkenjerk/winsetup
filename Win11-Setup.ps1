#Runs powershell window as admin if not already elevated.
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -Verb RunAs "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
    exit;
}

# Sets execution policy to bypass in order to run scripts and installs Chocolatey.
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Configures software for computer
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

# Installs Linux Subsystem for Windows
wsl --install


