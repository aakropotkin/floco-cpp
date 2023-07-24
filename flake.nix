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
      default = pkgsFor.floco-cpp;
    } );


# ---------------------------------------------------------------------------- #

    devShells = eachSupportedSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;

      floco-cpp-shell = let
        batsWith = pkgsFor.bats.withLibraries ( libs: [
          libs.bats-assert
          libs.bats-file
          libs.bats-support
        ] );
      in pkgsFor.mkShell {
        name       = "floco-cpp-shell";
        inputsFrom = [pkgsFor.floco-cpp];
        packages   = [
          batsWith
          pkgsFor.jq
        ];
        shellHook = ''
          alias gs='git status';
          alias ga='git add';
          alias gc='git commit -am';
          alias gl='git pull';
          alias gp='git push';
        '';
      };

    in {
      inherit (pkgsFor) floco-cpp;
      inherit floco-cpp-shell;
      default = floco-cpp-shell;
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
