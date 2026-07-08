{
  config,
  ...
}:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
in

{
  sourceDir,
  targetPrefix,
  force ? true,
}:
{
  "${targetPrefix}" = {
    source = mkOutOfStoreSymlink sourceDir;
    inherit force;
  };
}
