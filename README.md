# dotfiles.nix
🚀 dotfiles powered by Nix

### Prerequisites
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

### Usage
1. Clone repo
```shell
mkdir -p ~/.config
git clone git@github.com:goofansu/dotfiles.nix.git ~/.config/nixpkgs
```

2. Install `nixpkgs-unstable` and `home-manager`
```shell
cd ~/.config/nixpkgs
nix run . switch
```

3. Install the whole environment
```shell
home-manager switch -b bak
```
