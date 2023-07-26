# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ nixpkgs       ? builtins.getFlake "nixpkgs"
, floco         ? builtins.getFlake "github:aakropotkin/floco"
, system        ? builtins.currentSystem
, pkgsFor       ? nixpkgs.legacyPackages.${system}.extend floco.overlays.default
, stdenv        ? pkgsFor.stdenv
, sqlite        ? pkgsFor.sqlite
, pkg-config    ? pkgsFor.pkg-config
, nlohmann_json ? pkgsFor.nlohmann_json
, argparse      ? pkgsFor.argparse
, nix           ? pkgsFor.nix
, boost         ? pkgsFor.boost
, semver        ? pkgsFor.semver
}: import ./pkg-fun.nix {
  inherit stdenv sqlite pkg-config nlohmann_json argparse nix boost semver;
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
