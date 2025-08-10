{ pkgs, inputs, ... }:

{
  system.primaryUser = "alvin";
  
  users.users = {
    alvin = {
      home = "/Users/alvin";
      shell = pkgs.fish;
    };
  };

  programs.fish.enable = true;
}
