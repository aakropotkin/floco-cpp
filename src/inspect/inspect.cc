/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <fstream>
#include "floco/inspect.hh"
#include "floco/exception.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace inspect {

/* -------------------------------------------------------------------------- */

  bool
hasPackageJSON( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "package.json" );
}

  bool
hasPackageLock( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "package-lock.json" );
}

  bool
hasShrinkwrap( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "npm-shrinkwrap.json" );
}

  bool
hasYarnLock( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "yarn.lock" );
}

  bool
hasGypfile( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "binding.gyp" );
}

  bool
hasNmDir( const std::filesystem::path & tree )
{
  return std::filesystem::exists( tree / "node_modules" );
}


/* -------------------------------------------------------------------------- */

  nlohmann::json
getPackageJSON( const std::filesystem::path & tree )
{
  std::ifstream f( tree / "package.json" );
  return nlohmann::json::parse( f );
}

  nlohmann::json
getPackageLock( const std::filesystem::path & tree )
{
  std::ifstream f( tree / "package-lock.json" );
  return nlohmann::json::parse( f );
}

  nlohmann::json
getShrinkwrap( const std::filesystem::path & tree )
{
  std::ifstream f( tree / "npm-shrinkwrap.json" );
  return nlohmann::json::parse( f );
}


/* -------------------------------------------------------------------------- */

  std::list<std::string>
getBinPaths( const std::filesystem::path & tree
           , const nlohmann::json        & pjs
           )
{
  std::filesystem::path binDir;
  nlohmann::json        bin;
  try { bin = pjs.at( "bin" ); } catch( ... ) { return {}; }
  try
    {
      std::string relPath = bin.get<std::string>();
      if ( ! std::filesystem::exists( tree / relPath ) )
        {
          std::string msg = "No such file or directory: ";
          msg += tree;
          msg += "/" + relPath;
          throw FlocoException( msg );
        }

      if ( ! std::filesystem::is_directory( tree / relPath ) )
        {
          return { std::move( relPath ) };
        }
      else
        {
          std::filesystem::path relDir( relPath );
          std::list<std::string> rsl;
          for ( const auto & file :
                  std::filesystem::directory_iterator( tree / relPath )
              )
            {
              std::filesystem::path child = relDir / file.path().filename();
              rsl.emplace_back( child );
            }
          return rsl;
        }
    }
  catch ( ... )
    {
      std::list<std::string> rsl;
      for ( auto & [name, relPath] : bin.items() )
        {
          rsl.push_back( std::move( relPath ) );
        }
      return rsl;
    }
}


  std::list<std::string>
getBinPaths( const std::filesystem::path & tree )
{
  nlohmann::json pjs = getPackageJSON( tree );
  return getBinPaths( tree, pjs );
}


/* -------------------------------------------------------------------------- */


//nlohmann::json getYarnLock( const std::filesystem::path & tree );


/* -------------------------------------------------------------------------- */

  }  /* End namespace `floco::inspect' */
}  /* End namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
