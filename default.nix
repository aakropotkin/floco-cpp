# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs         ? builtins.getFlake "nixpkgs"
, floco-flake     ? builtins.getFlake "github:aakropotkin/floco"
, sqlite3pp-flake ? builtins.getFlake "github:aakropotkin/sqlite3pp"
, system          ? builtins.currentSystem
, pkgsFor         ? let
    ov = nixpkgs.lib.composeExtensions floco-flake.overlays.default
                                       sqlite3pp-flake.overlays.default;
  in nixpkgs.legacyPackages.${system}.extend ov
, stdenv        ? pkgsFor.stdenv
, sqlite        ? pkgsFor.sqlite
, pkg-config    ? pkgsFor.pkg-config
, nlohmann_json ? pkgsFor.nlohmann_json
, argparse      ? pkgsFor.argparse
, nix           ? pkgsFor.nix
, boost         ? pkgsFor.boost
, semver        ? pkgsFor.semver
, sqlite3pp     ? pkgsFor.sqlite3pp
}: import ./pkg-fun.nix {
  inherit
    stdenv sqlite sqlite3pp pkg-config nlohmann_json argparse nix boost semver
  ;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
