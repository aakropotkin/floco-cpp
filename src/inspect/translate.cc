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

  PdefCore
translate( std::string_view treeURL )
{
  util::initNix();

  std::string url( treeURL );
  nix::EvalState state( {}, nix::openStore() );

  nix::fetchers::Input original = nix::fetchers::Input::fromURL( url );
  auto [tree, locked]           = original.fetch( state.store );
  std::string treePath          = tree.actualPath;

  //nix::Hash      narHash   = locked.getNarHash().value();


  // TODO: move `floco::db::PjsCore' to `floco::PjsCore'
  nlohmann::json pjsRaw = getPackageJSON( treePath );
  db::PjsCore    pjs( pjsRaw );

  PdefCore pdef( pjs );
  pdef.fetcher   = locked.getType();
  pdef.fetchInfo = nix::fetchers::attrsToJSON( locked.toAttrs() );
  pdef.ltype     = treeURL.starts_with( "https://" ) ? LT_FILE : LT_DIR;

  // TODO: do this before trying to read `pjs'. This matters for `git' URIs.
  try
    {
      pdef.fsInfo.dir = std::get<std::string>( locked.toAttrs().at( "dir" ) );
    }
  catch( ... )
    {
      pdef.fsInfo.dir = ".";
    }

  pdef.fsInfo.gypfile    = hasGypfile( treePath );
  pdef.fsInfo.shrinkwrap = hasShrinkwrap( treePath );

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
