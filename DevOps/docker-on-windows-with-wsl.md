# Docker on Windows with WSL

The reason for using WSL instead of the **Docker Desktop** application is because of a high use of the resources of the system.
To prevent this, using WSL helps a lot doing this.

  
## Install & Update WSL
If WSL isn't istalled yet, with the following command it is installed:
```
wsl install
```
To update WSL the next command:
```
wsl --update
```
## Start WSL Distro
Starting WSL distro is done by this command(s):
```
# Run the default distro
wsl

# Run a selected distro
wsl -d <distro_name>
```
## Install Docker
For the installation the repo of docker has to be installed 1st. 
In this example the **Ubuntu** version is used. If you prefer another distro you have to look at the docker installation documentation site.

### 1. Install Docker Repo
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
### Install Docker
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Add user docker
```
sudo usermod -aG docker $USER
```
Add it to usergroup docker if not done automatically.
```
sudo addgroup docker
```
## Activate Docker on WSL start
For starting docker automatically on WSL start, the file */ect/wsl.conf* has to be changed / updated.
2nd a systemd command is neccessary.
### /etc/wsl.conf changement
Use the following command:
```
sudo nano /etc/wsl.conf
```
Change systemd to 'true'!
```
[boot]
systemd=true

[automount]
root = /
options = "metadata"
```
*systemd=true* means that Docker starts automatically on boot of WSL.
The amount option is for mounting every filesystem parts of Windows to WSL. This is optional and should be used, if you use for example another hard drive.

### systemctl command
Starting the docker service with systemd for starting the service on start:

```
sudo systemctl enable docker
```

## Automatic start at Windows start
1. Open Task Scheduler > Windows Tool
Press the Windows key, type "Task Scheduler" (or *Aufgabenplanung*), and open the program.

2. Create Basic Task
Click "Create Basic Task..." in the menu on the far right. Give it a name, such as "Docker-WSL-Autostart."

3. Set Trigger
For the trigger, select "At startup" (not "At logon," so that it is already running in the background before you log in).

4. Define Action
Select "Start a program" as the action. Simply enter "wsl" in the "Program/script" field. In the "Add arguments" field, enter the following (replace "Ubuntu" with your specific WSL distro if you are using a different one): *-d Ubuntu -u root -- systemctl start docker*

5. Adjust Permissions
Click "Finish." Locate the task in the list, right-click on it, and select "Properties." On the "General" tab, check the box labeled "Run with highest privileges" (since Docker requires root access) and select "Run whether user is logged on or not."

## Test Docker
Testing of docker by using following command:
```
docker run hello-world
```

## Commands outside of WSL
To handle commands in other terminals outside of WSL we can use following commands:

```
# with standard distro
wls docker run ....

# with using of distro
wls -d <distro_name> docker run ...

```

## Make Docker directly usable in Windows System
For using Docker directly under Windows, there are some several steps neccessary.

### Add Docker CLI to system variables & add DOCKER_HOST variable
Downlaod the current version of Docker: [Docker CLI](https://download.docker.com/win/static/stable/x86_64/)
Unzip it in an extra directory, e.g. *C:\Docker*

Update environment variables: Add the directory to system vaiables under **Path**.

Add the system variable with name **DOCKER_HOST* and the value **tcp://127.0.0.1:2375**
This is used later for the *Docker daemon* in WSL.

### Connect Docker CLI with WSL
Use the terminal with your wsl distribution and open the file deamon.json.
```[bash]
sudo nano /etc/docker/daemon.json
```
Add following lines:
```[JSON]
{
  "hosts": ["unix:///var/run/docker.sock", "tcp://127.0.0.1:2375"]
}
```
### Bypass WSL Password
To bypass the password we can add some information over *visudo* / *sudo visudo*.
```
username ALL=(ALL) NOPASSWD: /usr/sbin/service docker *
username ALL=(ALL) NOPASSWD: /usr/bin/dockerd
```
Replace **username** with your username.
### Add vsd program to auto start
Create a file with the name start-docker.vbs with the following content:
```
CreateObject("Wscript.Shell").Run "cmd /k wsl -d [distro] -u [username] sudo service docker stop && wsl -d [distro] -u root rm -f /var/run/docker.pid && wsl -d [distro] -u [username] sudo /usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://127.0.0.1:2375", 0, False
```
Replace **[distro]** with your distro or remove the distro including *-d*. 
Replace **[username]** with your username.

Add the file to auto-start.

## Install Docker Compose
For 

## Testing
Open a new terminal and use the command *docker ps*.

## Install Docker Compose on Windows
For using the command *docker compose* the installation of the it is neccessary.

