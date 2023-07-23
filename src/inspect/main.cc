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
  for ( const auto & f : inspect::getBinPaths( "/tmp/foo" ) )
    {
      std::cout << f << std::endl;
    }

  return EXIT_SUCCESS;
}
