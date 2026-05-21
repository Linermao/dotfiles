{
  hostConfig,
  root,
  lib,
}:

let
  toList =
    value:
    if value == null then
      [ ]
    else if builtins.isList value then
      value
    else
      [ value ];

  homeSelections = hostConfig.modules.home or { };
  systemSelections = hostConfig.modules.system or { };

  groupDir =
    group:
    {
      fileManager = "file-manager";
    }.${group} or group;

  modulePath = group: name: root + "/modules/nixos/home/${groupDir group}/${name}.nix";

  groupSelections = {
    ai = toList (homeSelections.ai or [ ]);
    coding = toList (homeSelections.coding or [ ]);
    display = toList (systemSelections.display or [ ]);
    fileManager = toList (homeSelections.fileManager or [ ]);
    programs = toList (homeSelections.programs or [ ]);
    shell = lib.optional (hostConfig.user.shell or null != null) hostConfig.user.shell;
    terminal = toList (homeSelections.terminal or [ ]);
  };
in
{
  inherit groupSelections;

  imports = lib.flatten (
    lib.mapAttrsToList (group: names: map (name: modulePath group name) names) groupSelections
  );
}
