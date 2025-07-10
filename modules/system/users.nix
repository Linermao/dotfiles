{ pkgs, inputs, ... }:

{
  users.users = {
    alvin = {
      isNormalUser = true;
      extraGroups = [ 
        "wheel" 
        "networkmanager" 
        "video"
        "input"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAzANerpEp/ZYczKFxJcOdzxDEtb4kP101eUZnhAABV8 LinermaoGemail@gmail.com"
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
