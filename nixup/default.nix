{ lib ? import <nixpkgs/lib>
, configuration ? lib.maybeEnv "NIXUP_CONFIG" <nixup-config>
, system ? builtins.currentSystem
}:

let

  eval = import ./lib/eval-config.nix {
    inherit lib;
    modules = [ configuration { nixpkgs.system = system; } ];
  };

in

{

  inherit (eval) config options;

  profile = eval.config.user.build.profile;

}
