{ pkgs, inputs, ... }:

{
  system.primaryUser = "alvin";
  
  # set fish as default shell
  users.knownUsers = [ "alvin" ];
  
  users.users = {
    alvin = {
      uid = 501;
      home = "/Users/alvin";
      shell = pkgs.fish;
    };
  };
  
  environment.shells = [ pkgs.fish ];
  programs.fish.enable = true;
}
