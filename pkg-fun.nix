# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

{ stdenv
, sqlite
, pkg-config
, nlohmann_json
, argparse
, nix
, boost
}: stdenv.mkDerivation {
  pname   = "floco-cpp";
  version = "0.1.0";
  src     = builtins.path {
    path = ./.;
    filter = name: type: let
      bname   = baseNameOf name;
      ignores = [
        "result"
        "default.nix"
        "pkg-fun.nix"
        ".git"
        ".gitignore"
        ".github"
        "LICENSE"
        "CONTRIBUTING.org"
        "README.org"
        ".ccls"
        ".ccls-cache"
        "out"
      ];
    in ( ! ( builtins.elem bname ignores ) ) &&
       ( ( builtins.match ".*\\.o" name ) == null );
  };
  nativeBuildInputs = [pkg-config];
  buildInputs       = [
    sqlite.dev nlohmann_json argparse nix.dev boost
  ];
  nix_INCDIR     = nix.dev.outPath + "/include";
  boost_CPPFLAGS = "-isystem " + boost.outPath + "/include";
  libExt         = stdenv.hostPlatform.extensions.sharedLibrary;
  configurePhase = ''
    runHook preConfigure;
    export PREFIX="$out";
    runHook postConfigure;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
