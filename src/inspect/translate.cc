/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <functional>
#include <nix/fetchers.hh>
#include <nix/store-api.hh>
#include <nix/eval-inline.hh>

#include "util.hh"
#include "floco/inspect.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace inspect {

/* -------------------------------------------------------------------------- */

/* This gets a single `pdef' from a tree. */
// TODO: translate dependencies recursively.
  PdefCore
translate( std::string_view treeURL )
{
  util::initNix();

  std::string url( treeURL );
  nix::EvalState state( {}, nix::openStore() );

  nix::fetchers::Input original = nix::fetchers::Input::fromURL( url );
  auto [tree, locked]           = original.fetch( state.store );
  //nix::Hash narHash           = locked.getNarHash().value();

  auto fia           = locked.toAttrs();
  std::string pjsDir = tree.actualPath;
  std::string fsDir  = ".";
  if ( auto mDir = fia.find( "dir" ); mDir != fia.end() )
    {
      fsDir  =  std::get<std::string>( ( * mDir ).second );
      pjsDir += "/" + fsDir;
    }

  nlohmann::json pjsRaw = getPackageJSON( pjsDir );
  PjsCore        pjs( pjsRaw );

  PdefCore pdef( pjs );
  pdef.fetcher   = locked.getType();
  pdef.fetchInfo = nix::fetchers::attrsToJSON( std::move( fia ) );
  pdef.ltype     = treeURL.starts_with( "https://" ) ? LT_FILE : LT_DIR;

  pdef.fsInfo.dir        = std::move( fsDir );
  pdef.fsInfo.gypfile    = hasGypfile( pjsDir );
  pdef.fsInfo.shrinkwrap = hasShrinkwrap( pjsDir );

  // TODO: sanity check `binInfo' to make sure `binDir' is a directory.

  return pdef;
}


/* -------------------------------------------------------------------------- */

  }  /* End namespace `floco::inspect' */
}  /* End namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
