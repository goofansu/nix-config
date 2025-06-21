# nix-config
My dev environment on macOS powered by [Nix](https://nixos.org).

## Prerequisites
- Nix: https://nixos.org/download/#nix-install-macos
- Homebrew: https://brew.sh/

## Install
Reference: [installing nix-darwin](https://github.com/nix-darwin/nix-darwin?tab=readme-ov-file#step-2-installing-nix-darwin)

```shell
git clone git@github.com:goofansu/nix-config.git ~/.config/nix-config
sudo nix run nix-darwin -- switch --flake ~/.config/nix-config
```

## Usage

### Apply changes
```shell
cd ~/.config/nix-config
sudo darwin-rebuild switch --flake .
```

### Update flake inputs
``` shell
cd ~/.config/nix-config
nix flake update
```

### Garbage collection
Reference: [nix-darwin wiki](https://github.com/LnL7/nix-darwin/wiki/Deleting-old-generations#for-multi-user-installation)

``` shell
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

## References
- [Tidying up your $HOME with Nix](https://juliu.is/tidying-your-home-with-nix/)
- [Nix Flakes, Part 1: An Introduction And Tutorial](https://www.tweag.io/blog/2020-05-25-flakes/)
- [Home Manager - Option Search](https://mipmip.github.io/home-manager-option-search/)
- [Darwin configuration options](https://daiderd.com/nix-darwin/manual/)
- [Uninstalling Nix - macOS](https://nixos.org/manual/nix/unstable/installation/uninstall.html#macos)
