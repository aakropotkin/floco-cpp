/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include <cstring>


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

enum DescriptorType {
  DT_NONE         = 0
, DT_URL          = 1
, DT_SEMVER_RANGE = 2
, DT_DIST_TAG     = 3
, DT_ERROR        = 4
};


/* -------------------------------------------------------------------------- */

/* TODO: Actually check that the string is a valid range.
 *
 * NOTE: Dist tags are "any non-URL and non-sermver-range".
 *       https://github.com/npm/cli/blob/latest/lib/commands/dist-tag.js */
  static inline DescriptorType
getDescriptorType( const char * desc )
{
  if ( strpbrk( desc, ":/" ) )            { return DT_URL;          }
  if ( strpbrk( desc, ".()|-<>=*~^" ) )   { return DT_SEMVER_RANGE; }
  if ( std::string_view( desc ).empty() ) { return DT_SEMVER_RANGE; }
  /* Hanlde `2' being short for `2.0.0-0 <= v < 3.0.0-0'*/
  for ( const char & c : std::string_view( desc ) )
    {
      if ( ! isdigit( c ) ) { return DT_DIST_TAG; }
    }
  return DT_SEMVER_RANGE;
}


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
