# nix-config
My dev environment powered by [Nix](https://nixos.org).

## Prerequisites

### Install Nix

```shell
curl -L https://nixos.org/nix/install | sh
```

### Install Homebrew
I use Homebrew Cask to install Applications that don't need to config.

``` shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Enable Nix flakes feature

```shell
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

## Install

```shell
git clone git@git.sr.ht:~goofansu/nix-config ~/.config/nix-config
nix run nix-darwin -- switch --flake ~/.config/nix-config
```

## Usage

### Build system 

```shell
darwin-rebuild switch --flake ~/.config/nix-config
```

### Upgrade packages

``` shell
cd ~/.config/nix-config
nix flake update
darwin-rebuild switch --flake ~/.config/nix-config
```

### Garbage collection

According to [nix-darwin wiki](https://github.com/LnL7/nix-darwin/wiki/Deleting-old-generations#for-multi-user-installation):

``` shell
sudo nix-collect-garbage -d
```

## References
- [Tidying up your $HOME with Nix](https://juliu.is/tidying-your-home-with-nix/)
- [Nix Flakes, Part 1: An Introduction And Tutorial](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Home Manager - Option Search](https://mipmip.github.io/home-manager-option-search/)
- [Darwin configuration options](https://daiderd.com/nix-darwin/manual/)
- [Uninstalling Nix - macOS](https://nixos.org/manual/nix/unstable/installation/uninstall.html#macos)
