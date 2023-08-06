# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{

# ---------------------------------------------------------------------------- #

  description = "C++ utilities for `floco' framework";

# ---------------------------------------------------------------------------- #

  # TODO: break dep cycle by moving `semver'
  inputs.floco.url                    = "github:aakropotkin/floco";
  inputs.floco.inputs.nixpkgs.follows = "/nixpkgs";

  inputs.sqlite3pp.url                    = "github:aakropotkin/sqlite3pp";
  inputs.sqlite3pp.inputs.nixpkgs.follows = "/nixpkgs";


# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, floco, sqlite3pp, ... } @ inputs: let

# ---------------------------------------------------------------------------- #


    eachSupportedSystemMap = fn: let
      supportedSystems = [
        "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"
      ];
      proc = system: { name = system; value = fn system; };
    in builtins.listToAttrs ( map proc supportedSystems );


# ---------------------------------------------------------------------------- #

    overlays.deps = nixpkgs.lib.composeExtensions floco.overlays.default
                                                  sqlite3pp.overlays.default;
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
          # For tests
          batsWith
          pkgsFor.jq
          # For profiling
          pkgsFor.lcov
          ( if pkgsFor.stdenv.cc.isGNU then pkgsFor.gdb else pkgsFor.lldb )
          # For doc
          pkgsFor.doxygen
        ] ++ ( if ! pkgsFor.stdenv.isLinux then [] else [
          # For debugging
          pkgsFor.valgrind
        ] );
        inherit (pkgsFor.floco-cpp) nix_INCDIR boost_CPPFLAGS libExt SEMVER;
        shellHook = ''
          shopt -s autocd;

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
