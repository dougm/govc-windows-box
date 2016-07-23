$setupDir=Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
Push-Location $setupDir
[Environment]::CurrentDirectory = $PWD

$kms = "kms-win8.eng.vmware.com"
$slmgr = "\windows\system32\slmgr.vbs"
$path = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"

if (-not(Get-ItemProperty $path)."KeyManagementServiceName") {
    Write-Host "Setting KMS server..."
    $proc = Start-Process "cscript.exe" -Wait -PassThru -NoNewWindow -ArgumentList @("/nologo", $slmgr, "-skms", $kms)
    if ($proc.ExitCode -ne 0) {
        Throw "set KMS server failed"
    }
}

if (-not(Get-ItemProperty $path)."IsActivated") {
    Write-Host "Activating installation against KMS..."
    $proc = Start-Process "cscript.exe" -Wait -PassThru -NoNewWindow -ArgumentList @("/nologo", $slmgr, "-ato")
    if ($proc.ExitCode -ne 0) {
        Throw "activate via KMS failed"
    }
    Set-ItemProperty -Path $path -Name "IsActivated" -Value 1
}

Write-Host "Disabling IE enhanced security..."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

Write-Host "Disabling windows firewall..."
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

$git_url = "https://github.com/git-for-windows/git/releases/download/v2.7.0.windows.1/Git-2.7.0-64-bit.exe"
$git_path = "c:\git\cmd"

if (-not(Test-Path -path "msysgit.exe")) {
    Write-Host "Downloading git..."
    (new-object System.Net.WebClient).DownloadFile($git_url, "msysgit.exe")
}

if (-not(Test-Path -path $git_path)) {
    Write-Host "Installing git..."
    $proc = Start-Process "msysgit.exe" -Wait -PassThru -NoNewWindow -ArgumentList @("/SILENT", "/DIR=c:\git")
    if ($proc.ExitCode -ne 0) {
        Throw "git install failed"
    }
}

if (-not($env:Path.Contains($git_path))) {
    Write-Host "Adding git bin to system PATH..."
    $env:Path += (";" + $git_path)
    [System.Environment]::SetEnvironmentVariable("PATH", $env:Path, "Machine")
}

if (-not(Test-Path -path "jdk8.exe")) {
    Write-Host "Downloading jdk8..."
    $client = new-object System.Net.WebClient
    $cookie = "oraclelicense=accept-securebackup-cookie"
    $client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
    $client.DownloadFile("http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-windows-x64.exe", "jdk8.exe")
}

if (-not(Test-Path -path "c:\jdk8")) {
    Write-Host "Installing jdk8..."
    $proc = Start-Process "jdk8.exe" -Wait -PassThru -NoNewWindow -ArgumentList @("/qn", "REBOOT=Supress", "INSTALLDIR=c:\jdk8")
    if ($proc.ExitCode -ne 0) {
        Throw "jdk install failed"
    }
}

$java_path = "c:\jdk8\bin"
if (-not($env:Path.Contains($java_path))) {
    Write-Host "Adding java bin to system PATH..."
    $env:Path += (";" + $java_path)
    [System.Environment]::SetEnvironmentVariable("PATH", $env:Path, "Machine")
}

if ($env:JAVA_HOME -ne "c:\jdk8") {
    Write-Host "Setting JAVA_HOME..."
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\jdk8", "Machine")
}

$maven_version = "3.3.3"
$maven_dir = ("apache-maven-" + $maven_version)
$maven_path = ("c:\" + $maven_dir + "\bin")
$maven_url = ("http://mirrors.gigenet.com/apache/maven/maven-3/" + $maven_version + "/binaries/" + $maven_dir + "-bin.zip")

if (-not(Test-Path -path "maven.zip")) {
    Write-Host "Downloading maven..."
    (new-object System.Net.WebClient).DownloadFile($maven_url, "maven.zip")
}

if (-not(Test-Path -path $maven_path)) {
    Write-Host "Unpacking maven..."
    Add-Type -assembly "System.IO.Compression.FileSystem"
    [System.IO.Compression.ZipFile]::ExtractToDirectory("maven.zip", "c:\")
}

if (-not($env:Path.Contains($maven_path))) {
    Write-Host "Adding maven bin to system PATH..."
    $env:Path += (";" + $maven_path)
    [System.Environment]::SetEnvironmentVariable("PATH", $env:Path, "Machine")
}

Write-Host "Finished"
