/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdlib>
#include <iostream>

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
      std::cerr << "You must provide a descriptor." << std::endl;
      return EXIT_FAILURE;
    }

  std::string ident( argv[1] );
  std::string descriptor( argv[2] );

/* -------------------------------------------------------------------------- */

  // TODO: move `floco::db::Packument' -> `floco::Packument'
  floco::registry::RegistryDb registry;

  std::optional<floco::db::PackumentVInfo> pvi =
    registry.resolve( ident, descriptor );

  if ( pvi.has_value() )
    {
      std::cout << pvi.value().toJSON().dump() << std::endl;
    }
  else
    {
      std::cerr << "'" << ident
                << "' does not have any versions for the descriptor '"
                << descriptor << "'." << std::endl;
    }


/* -------------------------------------------------------------------------- */

  return EXIT_SUCCESS;

}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
