/* ========================================================================== *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <list>
#include <functional>


/* -------------------------------------------------------------------------- */

namespace semver {

/* -------------------------------------------------------------------------- */

bool isSemver( const std::string & str );

  bool
isSemver( std::string_view str )
{
  return isSemver( std::string( str ) );
}


/* -------------------------------------------------------------------------- */

/* Pair of error-code and output string. */
std::pair<int, std::string> runSemver( const std::list<std::string> & args );

std::list<std::string> semverSat( const std::string            &  range
                                , const std::list<std::string> & versions
                                );


/* -------------------------------------------------------------------------- */

}  /* End namespace `semver' */

/* -------------------------------------------------------------------------- *
 *
 *
 * ========================================================================== */
