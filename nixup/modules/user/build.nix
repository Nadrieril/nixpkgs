{ config, lib, pkgs, ... }:

with lib;

{
  options = {

    user.build = mkOption {
      internal = true;
      type = types.attrsOf types.package;
      default = {};
      description = ''
        Attribute set of derivations used to setup the profile.
      '';
    };

    user.buildCommands = mkOption {
      internal = true;
      type = types.lines;
      default = [];
      example = literalExample ''
        "ln -s ${pkgs.firefox} $out/firefox-stable"
     '';
      description = ''
        List of commands to build and install the contents of the profile
        directory.
      '';
    };

  };

  config = {

    user.build.profile = pkgs.stdenv.mkDerivation {
      name = "nixup-profile";
      preferLocalBuild = true;
      buildCommand = ''
        source $stdenv/setup
        mkdir $out

        ${config.user.buildCommands}
      '';
    };

  };
}
