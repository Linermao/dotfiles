{ ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];

  nix.settings.trusted-users = [
    "root"
    "@nix"
  ];

  nixpkgs.config.allowUnfree = true;
}