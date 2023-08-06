/* ========================================================================== *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <list>
#include <regex>
#include <functional>


/* -------------------------------------------------------------------------- */

namespace semver {

/* -------------------------------------------------------------------------- */

  static inline bool
isSemver( const std::string & str )
{
  static const std::regex semverRE(
    "(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)(-[-[:alnum:]_+.]+)?"
  , std::regex::ECMAScript
  );
  return std::regex_match( str, semverRE );
}


/* -------------------------------------------------------------------------- */

/* Pair of error-code and output string. */
std::pair<int, std::string> runSemver( const std::list<std::string> & args );

std::list<std::string> semverSat( const std::string            & range
                                , const std::list<std::string> & versions
                                );


/* -------------------------------------------------------------------------- */

}  /* End namespace `semver' */

/* -------------------------------------------------------------------------- *
 *
 *
 * ========================================================================== */
