/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdlib>
#include <iostream>

#include "semver.hh"


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{

/* -------------------------------------------------------------------------- */

  if ( argc < 2 )
    {
      std::cerr << "You must provide a semantic version range." << std::endl;
      return EXIT_FAILURE;
    }
  if ( argc < 3 )
    {
      std::cerr << "You must provide a semantic version number." << std::endl;
      return EXIT_FAILURE;
    }

  std::string range( argv[1] );
  std::string version( argv[2] );

  if ( ! semver::isSemver( version ) )
    {
      std::cerr << "The provided string '" << version << "' is not a " <<
                   "semantic version number." << std::endl;
      return EXIT_FAILURE;
    }


/* -------------------------------------------------------------------------- */

  std::list<std::string> sats = semver::semverSat( range, { version } );

  if ( sats.empty() )
    {
      std::cerr << "'" << version << "' is not in the range '" << range << "'."
                << std::endl;
    }
  else
    {
      std::cout << version << std::endl;
    }


/* -------------------------------------------------------------------------- */

  return EXIT_SUCCESS;

}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
