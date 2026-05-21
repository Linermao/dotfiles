{
  config,
  lib,
}:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;

  recurse = {
    sourceDir,
    targetPrefix,
    exclude,
    relPath ? "",
  }:
    lib.foldlAttrs (
      acc: name: type:
      let
        nextRelPath = if relPath == "" then name else "${relPath}/${name}";
        sourcePath = sourceDir + "/${name}";
      in
      if builtins.elem nextRelPath exclude || builtins.elem name exclude then
        acc
      else if type == "directory" then
        acc // recurse {
          inherit targetPrefix exclude;
          sourceDir = sourcePath;
          relPath = nextRelPath;
        }
      else
        acc
        // {
          "${targetPrefix}/${nextRelPath}" = {
            source = mkOutOfStoreSymlink (toString sourcePath);
            force = true;
          };
        }
    ) { } (builtins.readDir sourceDir);
in

{
  sourceDir,
  targetPrefix,
  exclude ? [ ],
}:
recurse {
  inherit sourceDir targetPrefix exclude;
}
