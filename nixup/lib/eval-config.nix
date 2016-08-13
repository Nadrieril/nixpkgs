# From an end-user configuration file (`configuration'), build a NixUP
# configuration object (`config') from which we can retrieve option
# values.

{ lib ? import <nixpkgs/lib>
, baseModules ? import ../modules/module-list.nix
, modules
, extraArgs ? {}
, check ? true
, prefix ? []
}:

rec {

  # Merge the option definitions in all modules, forming the full
  # system configuration.
  inherit (lib.evalModules {
    inherit prefix check;
    modules = modules ++ baseModules;
    specialArgs = { pkgs = config.nixpkgs.pkgs; };
    args = extraArgs;
  }) config options;

}
