{
  config,
  lib,
  ...
}:
with lib; {
  options.filetype = {
    enable = mkEnableOption "Enable filetype management";

    literal = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Literal filetype matching";
    };

    extensions = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extension filetype matching";
    };
  };

  config = let
    cfg = config.filetype;
  in
    mkIf cfg.enable {
      autoCmd =
        (
          mapAttrsToList
          (name: ft: {
            event = ["BufRead" "BufNewFile"];
            pattern = name;
            command = "setfiletype ${ft}";
          })
          cfg.literal
        )
        ++ (mapAttrsToList (ext: ft: {
            event = "BufRead,BufNewFile";
            pattern = "*.${ext}";
            command = "setfiletype ${ft}";
          })
          cfg.extensions);
    };
}
