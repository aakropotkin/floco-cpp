/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdlib>
#include <iostream>

#include "semver.hh"
#include "registry-db.hh"


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{

/* -------------------------------------------------------------------------- */

  if ( argc < 2 )
    {
      std::cerr << "You must provide a package identifier." << std::endl;
      return EXIT_FAILURE;
    }
  if ( argc < 3 )
    {
      std::cerr << "You must provide a semantic version range." << std::endl;
      return EXIT_FAILURE;
    }

  std::string ident( argv[1] );
  std::string range( argv[2] );

/* -------------------------------------------------------------------------- */

  // TODO: move `floco::db::Packument' -> `floco::Packument'
  floco::registry::RegistryDb registry;
  floco::db::Packument        pack( ident, registry );

  std::list<std::string> versions;
  for ( const auto & [version, date] : pack.versions )
    {
      versions.push_back( version );
    }

  std::list<std::string> sats = semver::semverSat( range, versions );

  if ( sats.empty() )
    {
      std::cerr << "'" << ident << "' does not have any versions in the range '"
                << range << "'." << std::endl;
    }
  else
    {
      for ( const auto & version : sats )
        {
          std::cout << version << std::endl;
        }
    }


/* -------------------------------------------------------------------------- */

  return EXIT_SUCCESS;

}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
