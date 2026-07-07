<#
.SYNOPSIS
    Windows Docker CLI & Autostart Setup Script (Parameter-Driven)
.DESCRIPTION
    Richtet die Docker-CLI unter Windows ein und verknüpft sie mit der WSL.
    Erwartet optional die Parameter -DistroName und -WslUser.
#>
param (
    [string]$DistroName = "Ubuntu",  # Standardmäßig wird "Ubuntu" angenommen
    [string]$WslUser = $env:USERNAME, # Standardmäßig wird der aktuelle Windows-Username genommen
    [string]$DockerDir = "C:\Docker"
)

# Sicherheits-Check: Falls als Standard der Windows-User genommen wird, konvertieren wir ihn in Kleinschreibung (WSL-Standard)
$WslUser = $WslUser.ToLower()

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Starte Windows-Docker-Setup" -ForegroundColor Cyan
Write-Host " Ziel-Distribution: $DistroName" -ForegroundColor Yellow
Write-Host " WSL-Benutzername:  $WslUser" -ForegroundColor Yellow
Write-Host " Installationspfad: $DockerDir" -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Cyan

# 1. Verzeichnis prüfen/erstellen
if (!(Test-Path $DockerDir)) { 
    New-Item -ItemType Directory -Path $DockerDir | Out-Null 
}

# 2. Downloads der CLI-Tools
if (!(Test-Path "$DockerDir\docker.exe")) {
    Write-Host "Lade Docker CLI herunter..." -ForegroundColor Gray
    $DockerZip = "$DockerDir\docker.zip"
    Invoke-WebRequest -Uri "https://download.download.com/win/static/stable/x86_64/docker-27.1.1.zip" -OutFile $DockerZip -ErrorAction SilentlyContinue
    if (!(Test-Path $DockerZip)) {
        # Fallback falls statischer Link sich ändert
        Invoke-WebRequest -Uri "https://download.docker.com/win/static/stable/x86_64/docker-27.1.1.zip" -OutFile $DockerZip
    }
    Expand-Archive -Path $DockerZip -DestinationPath "$DockerDir\temp" -Force
    Move-Item "$DockerDir\temp\docker\*" $DockerDir -Force
    Remove-Item "$DockerDir\temp" -Recurse -Force
    Remove-Item $DockerZip -Force
}

if (!(Test-Path "$DockerDir\docker-compose.exe")) {
    Write-Host "Lade Docker Compose herunter..." -ForegroundColor Gray
    $ComposeUrl = "https://github.com/docker/compose/releases/download/v2.30.0/docker-compose-windows-x86_64.exe"
    Invoke-WebRequest -Uri $ComposeUrl -OutFile "$DockerDir\docker-compose.exe"
}

# 3. Dynamische IP-Ermittlung aus der angegebenen Distribution
Write-Host "Frage aktuelle IP aus WSL ($DistroName) ab..." -ForegroundColor Gray
$WslIp = ""
try {
    $WslIp = (wsl -d $DistroName -u $WslUser hostname -I 2>$null).Trim().Split(" ")[0]
} catch {
    # Ignorieren, Fehlerbehandlung folgt im nächsten Schritt
}

if ([string]::IsNullOrEmpty($WslIp)) {
    Write-Host "HINWEIS: Konnte keine Live-IP aus der Distribution '$DistroName' lesen." -ForegroundColor Orange
    Write-Host "Stelle sicher, dass die WSL installiert ist. Nutze vorerst localhost (127.0.0.1)." -ForegroundColor Orange
    $WslIp = "127.0.0.1"
} else {
    Write-Host "Erfolgreich verbundene WSL-IP: $WslIp" -ForegroundColor Green
}

# 4. Umgebungsvariablen permanent im System (Machine) hinterlegen
Write-Host "Setze Windows-Umgebungsvariablen..." -ForegroundColor Gray
$OldPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($OldPath -notlike "*$DockerDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$OldPath;$DockerDir", "Machine")
}
[Environment]::SetEnvironmentVariable("DOCKER_HOST", "tcp://$($WslIp):2375", "Machine")
$env:DOCKER_HOST = "tcp://$($WslIp):2375" # Für das aktuell offene Fenster

# 5. VBS-Autostart-Skript generieren
Write-Host "Erstelle start-docker.vbs im Autostart-Ordner..." -ForegroundColor Gray
$StartupFolder = [System.IO.Path]::Combine([Environment]::GetFolderPath("Startup"))
$VbsPath = "$StartupFolder\start-docker.vbs"

# Hier werden die Parameter dynamisch in den VBS-Text injiziert
$VbsContent = @"
Set shell = CreateObject("Wscript.Shell")
' 1. Docker via Systemd in WSL starten
shell.Run "cmd /c wsl -d $DistroName -u $WslUser sudo systemctl stop docker.socket && wsl -d $DistroName -u $WslUser sudo systemctl stop docker && wsl -d $DistroName -u $WslUser sudo systemctl start docker", 0, True

' 2. Die neue IP aus der WSL auslesen
Set fso = CreateObject("Scripting.FileSystemObject")
tmpFile = shell.ExpandEnvironmentStrings("%TEMP%") & "\wslip.txt"
shell.Run "cmd /c wsl -d $DistroName hostname -I > """ & tmpFile & """", 0, True

If fso.FileExists(tmpFile) Then
    Set file = fso.OpenTextFile(tmpFile, 1)
    if Not file.AtEndOfStream Then
        wslIp = Trim(file.ReadLine)
        ips = Split(wslIp, " ")
        wslIp = ips(0)
        
        ' 3. Die Windows-Umgebungsvariable permanent für das System updaten
        shell.RegWrite "HKLM\System\CurrentControlSet\Control\Session Manager\Environment\DOCKER_HOST", "tcp://" & wslIp & ":2375", "REG_SZ"
    End If
    file.Close
    fso.DeleteFile(tmpFile)
End If
"@

Set-Content -Path $VbsPath -Value $VbsContent -Force

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host " FERTIG! Das Setup wurde erfolgreich abgeschlossen." -ForegroundColor Green
Write-Host "==============================================================================" -ForegroundColor Green
