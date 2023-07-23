/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <stddef.h>
#include <iostream>
#include "floco/inspect.hh"

/* -------------------------------------------------------------------------- */

using namespace floco;


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp)
{
  if ( argc < 2 )
    {
      std::cerr << "You must provide a path to a directory!" << std::endl;
      return EXIT_FAILURE;
    }

  for ( const auto & f : inspect::getBinPaths( argv[1] ) )
    {
      std::cout << f << std::endl;
    }

  return EXIT_SUCCESS;
}
