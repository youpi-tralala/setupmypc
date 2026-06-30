# setupmypc

Windows is lame but I have no choice but to use it, so... this repo aims at setting up a debian vagrant box to code from.

## prerequisites are

- WSL has to be set up [see dedicated file for that](./configure_wsl.md)
- vagrant and oracle vbox needs to be installed in windows

## then

- vagrant box (debian bookworm) is pulled
- vm is created with vars from [*global_vars.yml*](./global_vars.yml)
  - network is *vbox host only* (for some reason bridged network was a pain in the glass to setup)
- *ops* (working_dir) and *C:\\* (as */mnt/c*) folder is shared with vm
- ansible set evrything else up

## Stupid things windows (and corporate restraictions) make me do

In order to use ansible (and deploy all of the scripts at the same time) I need a linux machine...

- so it's WSL by default
- so it's a nightmare with networking because of corporate restrictions
- so it's a nightmare with folders and links and permissions
- so I had to wrap Vagrant.exe in WSL (/home/yves/.local/bin/vagrant) because of networking issues
- so wrapped apps runs in windows with windows path, **hence a global_vars file to not mess all of that up**

## Architecture (component view)

```mermaid
flowchart LR
  subgraph WIN[Windows host]
    VBX[Oracle VirtualBox]
    VAGRANT_EXE[Vagrant.exe]
    STARTUP[Startup .bat auto-start VM]
    WIN_HOME[C:\\Users\\...]
  end

  subgraph WSL[WSL distro]
    RUN[run.sh]
    WRAP[wrapped vagrant binary]
    ANS_HOST[ansible-playbook playbook_host.yml]
    ANS_REMOTE[ansible-playbook -i inventory.ini playbook_remote.yml]
    VARS[global_vars.yml]
    INV[inventory.ini]
    SSHCFG[~/.ssh/config.d]
  end

  subgraph VM["Linux VM (Debian bookworm)"]
    CODEVM[code-vm]
    PKG[tools: git docker podman fish terraform powershell az]
    CERT[corporate cert: zscaler.crt]
    REPOS[apt repos: hashicorp + microsoft]
    OPSMNT[shared folder: /home/user/ops]
    CDRV["/mnt/c mapping"]
  end

  RUN --> VARS
  RUN --> ANS_HOST
  RUN --> WRAP
  RUN --> ANS_REMOTE

  WRAP --> VAGRANT_EXE --> VBX --> CODEVM
  ANS_HOST --> STARTUP
  ANS_HOST --> SSHCFG
  ANS_HOST --> INV

  INV --> ANS_REMOTE
  VARS --> ANS_REMOTE
  ANS_REMOTE --> PKG
  ANS_REMOTE --> CERT
  ANS_REMOTE --> REPOS

  WIN_HOME --> SSHCFG
  WIN_HOME --> VAGRANT_EXE

  CODEVM --> OPSMNT
  CODEVM --> CDRV

  classDef win fill:#ffe7e7,stroke:#b42318,color:#1f1f1f;
  classDef wsl fill:#e6f4ff,stroke:#175cd3,color:#1f1f1f;
  classDef vm fill:#eafbe7,stroke:#2d7a35,color:#1f1f1f;

  class VAGRANT_EXE,VBX,STARTUP,WIN_HOME win;
  class RUN,WRAP,ANS_HOST,ANS_REMOTE,VARS,INV,SSHCFG wsl;
  class CODEVM,PKG,CERT,REPOS,OPSMNT,CDRV vm;
```

## todo
set vscode config (sync settings?)
install vscode on vm + x11
include role hardening server
