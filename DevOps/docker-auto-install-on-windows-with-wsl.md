# Installation of Docker with Scripts

1st you need a WSL distribution. If no distro exists, install one distro. In all examples we use Ubuntu distribution.
```
wsl --install -d [distro] --name [distro_name]
```
The option *--name* is not required.

## Linux-Setup
Copy the file *docker-auto-install-on-windows-with-wsl-setup.sh* to your **WSL distribution** and execute it.

## Windows-Setup
Execute the file *docker-auto-install-on-windows-with-wsl-setup.ps1* at your Windows system:
```
setup-windows.ps1 -DistroName "[distro_name]" -WslUser "[WSL-User]"
```
- [distro_name]: Der Name der Distro (original oder benannt über Option --name)
- [WSL-User]: Der angelegte User in der WSL-Distribution

After executing both files, the setup has to be complete.
