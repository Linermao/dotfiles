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

  systemSelections = hostConfig.modules.system or { };

  modulePath = group: name: root + "/modules/nixos/system/${group}/${name}.nix";

  groupSelections = {
    display = toList (systemSelections.display or [ ]);
    gpu = (systemSelections.gpu.devices or [ ]) ++ [ "mode" ];
    programs = toList (systemSelections.programs or [ ]);
    servers = toList (systemSelections.servers or [ ]);
    virtualizations = toList (systemSelections.virtualizations or [ ]);
  };
in
{
  inherit groupSelections;

  imports = lib.flatten (
    lib.mapAttrsToList (group: names: map (name: modulePath group name) names) groupSelections
  );
}
