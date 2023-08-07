/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <iostream>
#include <functional>
#include <queue>
#include <list>

#include <nix/fetchers.hh>
#include <nix/store-api.hh>
#include <nix/eval-inline.hh>

#include "floco/exception.hh"
#include "floco/descriptor.hh"
#include "util.hh"
#include "floco/inspect.hh"
#include "registry-db.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace inspect {

/* -------------------------------------------------------------------------- */

  PdefCore
translateOne( std::string_view treeURL )
{
  util::initNix();

  std::string url( treeURL );
  nix::EvalState state( {}, nix::openStore() );

  nix::fetchers::Input original = nix::fetchers::Input::fromURL( url );
  auto [tree, locked]           = original.fetch( state.store );
  //nix::Hash narHash           = locked.getNarHash().value();

  auto        fia    = locked.toAttrs();
  std::string pjsDir = tree.actualPath;
  std::string fsDir  = ".";
  if ( auto mDir = fia.find( "dir" ); mDir != fia.end() )
    {
      fsDir  =  std::get<std::string>( ( * mDir ).second );
      pjsDir += "/" + fsDir;
    }

  nlohmann::json pjsRaw = getPackageJSON( pjsDir );
  PjsCore        pjs( pjsRaw );

  try
    {
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
  catch( ... )
    {
      std::cerr << "Translating '" << pjs.name << "@" << pjs.version << "'."
                << std::endl;
      throw;
    }
}


/* -------------------------------------------------------------------------- */

  std::pair<NvKey, NameVersionCollection>
translate( registry::RegistryDb & registry, std::string_view treeURL )
{
  PdefCore root    = translateOne( treeURL );
  NvKey    rootKey = std::make_pair( root.ident, root.version );

  NameVersionCollection rsl;
  rsl.emplace(
    root.ident
  , (std::unordered_map<floco::version, PdefCore>) { { root.version, root } }
  );

  std::queue<db::PackumentVInfo, std::list<db::PackumentVInfo>> todo;
  for ( const auto & [ident, ent] : root.depInfo )
    {
      std::optional<db::PackumentVInfo> res =
        registry.resolve( ident, ent.descriptor );
      if ( ! res.has_value() )
        {
          std::string msg( "Failed to resolve '" );
          msg += ident;
          msg += '@';
          msg += ent.descriptor;
          msg += ".'";
          throw FlocoException( msg );
        }
      todo.push( res.value() );
    }

  while ( ! todo.empty() )
    {
      db::PackumentVInfo vi = todo.front();
      todo.pop();
      auto i = rsl.find( vi.name );
      if ( i == rsl.end() )
        {
          rsl.emplace( vi.name
                     , (std::unordered_map<floco::version, PdefCore>) {}
                     );
        }
      i = rsl.find( vi.name );
      auto v = i->second.find( vi.version );
      if ( v != i->second.end() ) { continue; }
      i->second.emplace( vi.version
                       , translateOne( vi.dist["tarball"].get<std::string>() )
                       );
      v = i->second.find( vi.version );
      for ( const auto & [ident, ent] : v->second.depInfo )
        {
          std::optional<db::PackumentVInfo> res =
            registry.resolve( ident, ent.descriptor );
          if ( ! res.has_value() )
            {
              std::string msg( "Failed to resolve '" );
              msg += ident;
              msg += '@';
              msg += ent.descriptor;
              msg += "'.";
              throw FlocoException( msg );
            }
          todo.push( res.value() );
        }
    }

  return make_pair( rootKey, rsl );
}


/* -------------------------------------------------------------------------- */

  }  /* End namespace `floco::inspect' */
}  /* End namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
