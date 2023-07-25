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

  floco::PdefCore pdef = floco::inspect::translate( argv[1] );

  std::cout << pdef.toJSON().dump() << std::endl;

  return EXIT_SUCCESS;
}  /* End `main' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
