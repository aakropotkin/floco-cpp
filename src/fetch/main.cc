/* ========================================================================== *
 *
 * USAGE:  fetch [-o <OUT-FILE>] URL
 *
 * -------------------------------------------------------------------------- */

#include <stdlib.h>
#include <argparse/argparse.hpp>
#include <iostream>
#include <stdexcept>
#include <string>

#include "fetch.hh"


/* -------------------------------------------------------------------------- */

  int
main( int argc, char * argv[], char ** envp )
{

/* -------------------------------------------------------------------------- */

  argparse::ArgumentParser prog( "fetch", "0.1.0" );
  prog.add_description( "Fetch a file from a URL" );

  prog.add_argument( "url" )
    .help( "URL to be fetched" )
    .metavar( "URL" );

  prog.add_argument( "-o", "--output" )
    .default_value( std::string( "-" ) )
    .help( "Path to save fetched result" )
    .metavar( "OUT-FILE" );

  try
    {
      prog.parse_args( argc, argv );
    }
  catch ( const std::runtime_error & err )
    {
      std::cerr << err.what() << std::endl << prog;
      return EXIT_FAILURE;
    }


/* -------------------------------------------------------------------------- */

  auto url    = prog.get<std::string>( "url" );
  auto output = prog.get<std::string>( "output" );

  if ( output == "-" ) { output = "/dev/stdout"; }


/* -------------------------------------------------------------------------- */

  try
    {
      floco::fetch::fetchFileTo( url.c_str(), output.c_str() );
    }
  catch( std::filesystem::filesystem_error & e )
    {
      std::cout << e.what() << std::endl;
      return EXIT_FAILURE;
    }


/* -------------------------------------------------------------------------- */

  return EXIT_SUCCESS;
}


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
