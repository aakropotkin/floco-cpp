/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <stddef.h>
#include <iostream>

#include "floco/inspect.hh"
#include "pdef.hh"


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp)
{
  if ( argc < 2 )
    {
      std::cerr << "You must provide a URL!" << std::endl;
      return EXIT_FAILURE;
    }

  floco::registry::RegistryDb db;


  auto [rootKey, translations] = floco::inspect::translate( db, argv[1] );

  std::cerr << "Root: " << rootKey.first << "@" << rootKey.second << std::endl;
  nlohmann::json j = translations;
  std::cout << j.dump() << std::endl;

  return EXIT_SUCCESS;
}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
