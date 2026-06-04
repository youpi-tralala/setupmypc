# setupmypc

Windows is lame but I have to use it so... this repo aim at setting up a debian vagrant box to code from.

## prerequisites are

- WSL has to be set up (see dedicated file for that)
- vagrant and oracle vbox needs to be installed

## then

- vagrant box (debian bookworm) is pulled
- vm is created with vars from *global_vars.yml*
  - network is *vbox host only* (for some reason bridged network was a pain in the glass to setup)
- *ops* and *.ssh* folder are shared with vm
- ansible set it up with necessary paquets

## Stupid things windows make me do

In order to use ansible I need a linux machine..

- so it's WSL by default
- so it's a nightmare with networking
- so it's a nightmare with folders
- so apps like Vagrant or Multipass are wrapped in WSL (/home/yves/.local/bin/)
- so wrapped apps runs on windows with windows path, **hence a global_vars file to not mess all of that up**