# wsl

>[!IMPORTANT] OS is Debian 13 (Trixie)

## Install

<https://learn.microsoft.com/fr-fr/windows/wsl/basic-commands>

```powershell
# list distributions
wsl --list --online
# install distribution with selected location
wsl --install --distribution Debian --location "C:\Users\<user>\wsl"
```

### Sudo

```sh
# Set user as sudoers w/o password
echo "<user> ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/<user>
```

### Folders to create

```sh
mkdir -p /home/<user>/.local/bin
mkdir -p /home/<user>/.ssh/{config,config.d}
```

### Mandatories options

```sh
grep -R 'Include config.d/*' ~/.ssh/config || \
cat << EOF >> ~/.ssh/config
Include config.d/*
EOF
```

### Interoperability WSL <> Widows

```sh
cat << EOF > /etc/wsl.conf
[boot]
systemd=true

[interop]
enabled = true
appendWindowsPath = true

[automount]
enabled = true
root = /mnt/
options = "uid=1000,gid=1000,umask=22,fmask=11"
EOF
```

### Zscaler

To bypasser Zscaler, its root certificates needs to be in `/usr/local/share/ca-certificates/zscaler.crt`

```crt
-----BEGIN CERTIFICATE-----
<paste certificate here>
-----END CERTIFICATE-----
```

 Zscaler intercept and replace the original certificate.
 To retrieve the root certificate:

- Visit any HTTPS site (e.g., <https://google.com>)
- Click the lock icon → Certificate
- find the **top-level Zscaler Root CA**
- Export it as **Base64 / PEM (.crt)**
 then

 ```sh
 sudo update-ca-certificates
 ```

## Paquets

### apt

```sh
apt update -y
apt install -y openssh-client vim terminator curl wget locate git gpg ansible azure-cli podman fish snapd whois jq original-awk yq tree xauth
```

### Terraform

```sh
# bypass Zscaler before 
sudo snap install snapd
sudo snap install terraform --classic
```

### PowerShell

```powershell
powershell.exe -ExecutionPolicy Bypass -c 'irm https://astral.sh/uv/install.ps1 | iex'
```

## Fish

```sh
# switch to fish
fish
# Optionnal:
# configure fish as default shell for current user
chsh -s $(which fish)
# add to $PATH
set -U fish_user_paths /home/<user>/.local/bin $fish_user_paths
```

## Links

```sh
# SSH
ln -s C:\Users\<user>\.ssh /home/<user>/.ssh
$ chmod 600 .ssh/<ssh_key>
$ chmod 644 .ssh/<ssh_key>.pub
# Working dir
ln -s /mnt/c/Users/<user>/working_dir/ /home/<user>/working_dir
```

## Github

configure ssh config file

```ini
host git-perso
  hostname github.com
        User <github_user>
        IdentityFile ~/.ssh/<user>@personal_mail
        
host github.com
  hostname github.com
        User <github_user>
        IdentityFile ~/.ssh/<user>@pro_mail
```

test connection

```sh
ssh -T git@github.com
ssh -T git@git-perso
```

configure git config
>[!NOTE] est-ce que c'est toujours necessaire si .ssh/config est configuré pour différencier les alias?

```sh
  # per repo
  git config --local user.email "<user>@personal_mail"
  git config --local user.name "<github_user>"
  # all repo
  git config --global user.email "<user>@personal_mail"
  git config --global user.name "<github_user>"
  
  # Set line ending to LF
  git config --global core.autocrlf false
```

git config perso example
>[!NOTE] penser à modifier l'alias `git-perso` dans l'url de origin

```sh
[core]
    repositoryformatversion = 0
    filemode = false
    bare = false
    logallrefupdates = true
    ignorecase = true
[remote "origin"]
    url = git@git-perso:<github_user>/some_repo.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
    remote = origin
    merge = refs/heads/main
[user]
    email = <user>@personal_mail
    name = <github_user>
```

## Vagrant

Too many failure when using Vagrant in WSL.

- [install in windows from exe](https://developer.hashicorp.com/vagrant/install)
- wrap it to call it from WSL

```sh
cat <<'EOT' > ~/.local/bin/vagrant
#!/usr/bin/env bash
set -euo pipefail

exec powershell.exe -NoProfile -Command "vagrant --% $*"
EOT
chmod +x ~/.local/bin/vagrant
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
