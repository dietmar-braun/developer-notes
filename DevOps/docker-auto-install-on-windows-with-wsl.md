# Installation of Docker mit Skripten

Im ersten Schritt ist es notwenidig, dass eine WSL Distribution installiert wird oder bereits besteht.
```
wsl --install -d [distro] --name [distro_name]
```
Die Option *--name* ist optional.

## Linux-Setup
Erstelle eine docker-auto-install-on-windows-with-wsl-setup.sh* Datei und kopiere den Inhalt von setup-docker.sh hinein.
Führe das Skript in **WSL** aus.

## Windows-Setup
Führe das Skript *docker-auto-install-on-windows-with-wsl-setup.ps1* aus:
```
setup-windows.ps1 -DistroName "[distro_name]" -WslUser "[WSL-User]"
```
- [distro_name]: Der Name der Distro (original oder benannt über Option --name)
- [WSL-User]: Der angelegte User in der WSL-Distribution
