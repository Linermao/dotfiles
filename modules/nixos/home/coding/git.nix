{ hostConfig, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = hostConfig.user.git.name or hostConfig.user.name;
      email = hostConfig.user.git.email;
    };
  };
}
