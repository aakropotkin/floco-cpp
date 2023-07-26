/* ========================================================================== *
 *
 *
 * -------------------------------------------------------------------------- */

#include <regex>
#include <cstdlib>

#include "semver.hh"
#include <nix/util.hh>


/* -------------------------------------------------------------------------- */

namespace semver {

/* -------------------------------------------------------------------------- */

/* Matches Semantic Version strings, e.g. `4.2.0-pre' */
#define _re_vp "(0|[1-9][0-9]*)"
static const std::regex semverRE(
  _re_vp "\\." _re_vp "\\." _re_vp "(-[-[:alnum:]_+.]+)?"
, std::regex::ECMAScript
);


/* -------------------------------------------------------------------------- */

  bool
isSemver( const std::string & str )
{
  return std::regex_match( str, semverRE );
}


/* -------------------------------------------------------------------------- */

// TODO: config.h

#ifndef SEMVER_PATH
#  define SEMVER_PATH  semver
#endif
#define _XSTRIZE( _S )   _STRIZE( _S )
#define _STRIZE( _S )    # _S
#define SEMVER_PATH_STR  _XSTRIZE( SEMVER_PATH )


/* -------------------------------------------------------------------------- */

  std::pair<int, std::string>
runSemver( const std::list<std::string> & args )
{
  static const std::map<std::string, std::string> env = nix::getEnv();
  static const std::string semverProg =
    nix::getEnv( "SEMVER" ).value_or( SEMVER_PATH_STR );
  return nix::runProgram( {
    .program     = semverProg
  , .searchPath  = true
  , .args        = args
  , .environment = env
  } );
}


/* -------------------------------------------------------------------------- */

// TODO: throw errors based on wrapped exit status.

  std::list<std::string>
semverSat( const std::string & range, const std::list<std::string> & versions )
{
  std::list<std::string> args = {
    "--include-prerelease", "--loose", "--range", range
  };
  for ( auto & v : versions ) { args.push_back( v ); }
  auto [ec, lines] = runSemver( args );
  if ( ! nix::statusOk( ec ) ) { return {}; }
  std::list<std::string> rsl;
  std::stringstream ss( lines );
  std::string l;
  while ( std::getline( ss, l, '\n' ) )
    {
      if ( ! l.empty() ) { rsl.push_back( std::move( l ) ); }
    }
  return rsl;
}


/* -------------------------------------------------------------------------- */

}  /* End namespace `semver' */

/* -------------------------------------------------------------------------- *
 *
 *
 * ========================================================================== */
