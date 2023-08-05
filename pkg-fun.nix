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
, semver
, sqlite3pp
}: stdenv.mkDerivation {
  pname   = "floco-cpp";
  version = "0.1.0";
  src     = builtins.path {
    path = ./.;
    filter = name: type: let
      bname   = baseNameOf name;
      ext     = let
        m = builtins.match ".*/[^/]+\\.([^/])" name;
      in if m == null then "" else builtins.head m;
      ignores = [
        "flake.lock"
        ".git"
        ".gitignore"
        ".github"
        "LICENSE"
        ".ccls"
        ".ccls-cache"
        "out"
        ".stamp"
      ];
      extIgnores = ["org" ".o" "so" "a" "dylib" "nix"];
      notIgnored = ( ! ( builtins.elem bname ignores ) ) &&
                   ( ! ( builtins.elem ext   extIgnores ) );
      notBin     = ( baseNameOf ( dirOf name ) ) != "bin";
      notResult  = ( builtins.match ".*/result(-*)?" name ) == null;
      isSrc      = builtins.elem ext ["cc" "hh" "ipp"];
    in isSrc || ( notIgnored && notBin && notResult );
  };
  nativeBuildInputs = [pkg-config];
  buildInputs       = [
    sqlite.dev sqlite3pp nlohmann_json argparse nix.dev boost
  ];
  propagatedBuildInputs = [semver];
  nix_INCDIR            = nix.dev.outPath + "/include";
  boost_CPPFLAGS        = "-isystem " + boost.outPath + "/include";
  libExt                = stdenv.hostPlatform.extensions.sharedLibrary;
  SEMVER                = semver.outPath + "/bin/semver";
  configurePhase        = ''
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
