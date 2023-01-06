{
  config,
  lib,
  ...
}:
with lib; {
  options.autocommands = mkOption {
    type = types.listOf (types.submodule {
      options = {
        event = mkOption {type = types.str;};
        trigger = mkOption {type = types.str;};
        command = mkOption {type = types.str;};
      };
    });
    default = [];
  };

  config = {
    extraConfigVim = concatStringsSep "\n" (
      map
      (au: "au ${au.event} ${au.trigger} ${au.command}")
      config.autocommands
    );
  };
}
