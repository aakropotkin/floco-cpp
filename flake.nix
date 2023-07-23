# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description = "C++ utilities for `floco' framework";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, ... } @ inputs: let

# ---------------------------------------------------------------------------- #


    eachSupportedSystemMap = fn: let
      supportedSystems = [
        "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
      ];
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc supportedSystems );


# ---------------------------------------------------------------------------- #

    overlays.deps      = final: prev: {};
    overlays.floco-cpp = import ./overlay.nix;
    overlays.default   = nixpkgs.lib.composeExtensions overlays.deps
                                                       overlays.floco-cpp;


# ---------------------------------------------------------------------------- #

  in {  # Begin `outputs'

# ---------------------------------------------------------------------------- #

    inherit (nixpkgs) lib;

# ---------------------------------------------------------------------------- #

    inherit overlays;

# ---------------------------------------------------------------------------- #

    packages = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
    in {
      inherit (pkgsFor) floco-cpp;
      default = floco-cpp;
    } );


# ---------------------------------------------------------------------------- #

  };  # End `outputs'


# ---------------------------------------------------------------------------- #

}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
