# OpenSSH for Windows 7

## Requirements

```text
1. .NET Framework 4.5.2
2. WMF 5.1
```

## Usage

```powershell
powershell -executionpolicy bypass -File install_openssh.ps1
```

## Results

```powershell
PS C:\Users\Administrator\Desktop\test> .\openssh.ps1


    Directory: C:\Program Files


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d-----         9/3/2020   6:26 PM                OpenSSH
-Object
Unzip file from [win7_open_ssh.zip] to [.]
[SC] SetServiceObjectSecurity SUCCESS
[SC] ChangeServiceConfig2 SUCCESS
[SC] ChangeServiceConfig2 SUCCESS
sshd and ssh-agent services successfully installed
C:\Program Files\OpenSSH\ssh-keygen.exe -A

Status      : Running
Name        : sshd
DisplayName : OpenSSH SSH Server


Status      : Running
Name        : ssh-agent
DisplayName : OpenSSH Authentication Agent
```

## Reference

* [.NET Framework 4.5.2](https://www.microsoft.com/en-us/download/details.aspx?id=42642)
* [WMF 5.1](https://docs.microsoft.com/zh-tw/powershell/scripting/windows-powershell/wmf/setup/install-configure?view=powershell-7)
