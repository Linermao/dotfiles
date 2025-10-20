{ pkgs, inputs, ... }:

{
  users.groups.i2c = {};

  users.users = {
    alvin = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel" 
        "networkmanager" 
        "video"
        "input"
        "vboxusers"
        "disk"
        "docker"
        "libvirtd"
        "kvm"
        "i2c"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+N3j3ytRRUXM4+dgLosNhI1KbkWG/2ttOwXodsPADm LinermaoGemail@gmail.com"
      ];
      shell = pkgs.fish;
    };

    # Linermao = {
    #   isNormalUser = true;
    #   extraGroups = [ 
    #     "wheel" 
    #     "networkmanager" 
    #     "video"
    #     "input"
    #   ];
    #   shell = pkgs.fish;
    # };
  };
  
  programs.fish.enable = true;
}
