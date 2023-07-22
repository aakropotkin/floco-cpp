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
    path = ../.;
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
      ];
    in if type == "directory"
       then bname != "out"
       else ! ( builtins.elem bname ignores );
  };
  libExt            = stdenv.hostPlatform.extensions.sharedLibrary;
  nativeBuildInputs = [pkg-config];
  buildInputs       = [
    sqlite.dev nlohmann_json argparse nix.dev boost
  ];
  makeFlags = [
    "nix_INCDIR=${nix.dev}/include"
    "boost_CFLAGS=-I${boost}/include"
    "libExt=${stdenv.hostPlatform.extensions.sharedLibrary}"
  ];
  configurePhase = ''
    runHook preConfigure;
    export PREFIX="$out";
    runHook postConfigure;
  '';
  buildPhase = ''
    runHook preBuild;
    cd ./cli;
    eval "make $makeFlags";
    runHook postBuild;
  '';
}


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #