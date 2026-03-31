{ pkgs, ... }:

{
  users.knownUsers = [ "alvin" ];

  users.users.alvin = {
    uid = 501;
    home = "/Users/alvin";
    shell = pkgs.fish;
  };
}
