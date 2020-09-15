[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
# ================== Functions ====================
$log_file = "openssh_installation.log"
function Log_Write {
    Param ([string]$log_string)
    Add-Content $log_file -Value $log_string
}

function Log_Write_Error {
    Param ([string]$log_string)
    Add-Content $log_file -Value "[Error] $log_string"
}

function Download_File {
    param ([string]$url, [string]$output)
    Log_Write "Start to download file from -> $url..."
    Log_Write "Download file to -> $output..."
    $start_time = Get-Date
    Invoke-WebRequest -Uri $url -OutFile $output
    Log_Write "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}


function Unzip_File {
    param ([string]$zip_path, [string]$dest_path)
    Write-Output -Object "Unzip file from [${zip_path}] to [${dest_path}]"
    Expand-Archive -Path "$zip_path" -DestinationPath "$dest_path"
    Log_Write "Unzip file completed!"
}

function Get_Download_URL {
    $openssh_base_url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v8.1.0.0p1-Beta"
    $openssh_url = ""

    if ([Environment]::Is64BitProcess) {
        Log_Write "Install Win64 OpenSSH"
        $openssh_url = $openssh_base_url + "/OpenSSH-Win64.zip"
    }
    else {
        Log_Write "Install Win32 OpenSSH"
        $openssh_url = $openssh_base_url + "/OpenSSH-Win32.zip"
    }
    return $openssh_url
}


function Get_Unzip_Path {
    $unzip_path = ""
    if ([Environment]::Is64BitProcess) {
        $unzip_path = ".\OpenSSH-Win64"
    }
    else {
        $unzip_path = ".\OpenSSH-Win32"
    }
    Log_Write "Unzip path -> [$unzip_path]"
    return $unzip_path
}

function Create_OpenSSH_Install_Folder {
    param ([string]$dir)
    try {
        New-Item -ItemType "directory" -Path $dir
    }
    catch {
        Log_Write "Create install folder failed, maybe already exist"
    }
}


function Create_Ssh_Firewall_Rule {
    try {
        New-NetFirewallRule -Name sshd -DisplayName "OpenSSH Firewall" |
        -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
    catch {
        Log_Write "Create Firewall Failed"
    }
}


function Start_Ssh_Service {
    Log_Write "Strating SSH Service"
    Set-Service sshd -StartupType Automatic
    Set-Service ssh-agent -StartupType Automatic
    Start-Service sshd
    Start-Service ssh-agent
    Get-Service sshd
    Get-Service ssh-agent
}


function OpenSSH_Installation {
    param ([string]$openssh_url)

    # download file and extract to C:\
    $openssh_zip = "win7_open_ssh.zip"
    Download_File $openssh_url $openssh_zip
    $openssh_install_folder = Join-Path -Path ${env:ProgramFiles} -ChildPath "OpenSSH"
    Create_OpenSSH_Install_Folder $openssh_install_folder
    Unzip_File $openssh_zip "."

    $unzipped_path = Get_Unzip_Path
    Copy-Item -Path "$unzipped_path\*" -Destination $openssh_install_folder -Recurse
    Remove-Item -Path "$unzipped_path" -Force -Recurse
    Remove-Item $openssh_zip

    # run install script
    Log_Write "Run SSH install script..."
    $install_sshd_ps1 = "$openssh_install_folder\install-sshd.ps1"
    powershell -executionpolicy bypass -File $install_sshd_ps1

    # generate key
    "$openssh_install_folder\ssh-keygen.exe -A"

    Start_Ssh_Service
    Log_Write "Install SSH Service completed!"

    # add firewall for sshd
    Create_Ssh_Firewall_Rule
}

function Main {
    $openssh_url = Get_Download_URL
    OpenSSH_Installation $openssh_url
}

# ==================== Main ====================
Main