{
  config,
  pkgs,
  lib,
  ...
}:
with lib; {
  options.plugins.editorconfig = {
    enable = mkEnableOption "Enable editorconfig-vim";

    extraProperties = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = ''
        Defines a callback function which accepts the number of the buffer to be modified, the
        value of the property in the .editorconfig file, and (optionally) a table containing all of
        the other properties and their values (useful for properties which depend on
        other properties)
      '';
      example = {
        foo = ''
          function(bufnr, val, opts)
             if opts.charset and opts.charset ~= "utf-8" then
               error("foo can only be set when charset is utf-8", 0)
             end
             vim.b[bufnr].foo = val
           end
        '';
      };
    };
  };

  config = let
    cfg = config.plugins.editorconfig;
  in
    mkIf cfg.enable {
      extraPlugins = with pkgs.vimPlugins; [editorconfig-nvim];
      extraConfigLua = concatStringsSep "\n" (
        lib.mapAttrsToList (
          prop: func: ''require('editorconfig').properties.${prop} = ${func}''
        )
        cfg.extraProperties
      );
    };
}
