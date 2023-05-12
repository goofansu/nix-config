# dotfiles.nix
My `$HOME` configuration powered by [Nix](https://nixos.org) and [home-manager](https://github.com/nix-community/home-manager).

## Install
1. Install Nix

```shell
sh <(curl -L https://nixos.org/nix/install)
```

2. Enable Nix flakes

```shell
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

3. Install [Home Manager](https://github.com/nix-community/home-manager)

```shell
git clone git@github.com:goofansu/dotfiles.nix.git ~/.config/home-manager
cd ~/.config/home-manager
nix run . switch
```

From now on, you can manage your environment with the `home-manager` command.

## Usage

### Build and activate current configuration

```shell
home-manager switch -b bak
```

### Rollback to a previous configuration

Home Manager keeps a list of generations for your configuration, so if something goes wrong, you can activate previous generation.

1. List all generations

``` shell
$ home-manager generations

2023-02-24 15:58 : id 137 -> /nix/store/8j3jnnbrfpcn103snqhw8nd8wcv952r9-home-manager-generation
2023-02-24 15:16 : id 136 -> /nix/store/xdp7c82dlzni9vildz2dpr869rrpj1db-home-manager-generation
2023-02-24 14:16 : id 135 -> /nix/store/fjyvxlpg6rnglrlk2km4l248m3fa7mgh-home-manager-generation
```

2. Select a generation and activate it

``` shell
$ /nix/store/fjyvxlpg6rnglrlk2km4l248m3fa7mgh-home-manager-generation/activate
```

