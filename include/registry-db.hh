/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <string>
#include "pjs-core.hh"
#include <optional>
#include "packument.hh"
#include "util.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

class RegistryDb : public PkgRegistry {
  private:
    std::string                          _dbPath;
    std::unique_ptr<sqlite3pp::database> _db;

  public:
    RegistryDb(
      std::string_view             host     = "registry.npmjs.org"
    , std::string_view             protocol = "https"
    , std::optional<PkgRegistry *> fallback = std::nullopt
    ) : PkgRegistry( host, protocol, fallback )
      , _dbPath( util::getRegistryDbPath( host ) )
    {}

    RegistryDb( PkgRegistry && reg )
      : PkgRegistry( std::move( reg ) )
      , _dbPath( util::getRegistryDbPath( reg.host ) )
    {}

    RegistryDb( const PkgRegistry & reg )
      : PkgRegistry( reg ), _dbPath( util::getRegistryDbPath( reg.host ) )
    {}

    bool exists() const;
    bool create( bool recreate = false );

    std::string_view getDbPath() const { return this->_dbPath; }

    std::reference_wrapper<sqlite3pp::database> getDb( bool create = true );

      bool
    has( floco::ident_view ident )
    {
      return this->exists() && db::db_has( this->getDb().get(), ident );
    }

      bool
    stale( floco::ident_view ident )
    {
      return ( ! this->exists() ) || db::db_stale( this->getDb().get(), ident );
    }

    db::Packument      get( floco::ident_view   ident );
    db::PackumentVInfo get( floco::ident_view   ident
                          , floco::version_view version
                          );

    /**
     * Resolve a dependency request in a registry by semantic version range or
     * dist tag.
     * @param ident Package identifier ( name ) to resolve.
     * @param rangeOrTag Semantic version range used to filter version list, or
     *                   a `distTag` name such as `latest` or `stable`.
     * @return `std::nullopt` is no satisfactory matches are found, otherwise
     *          the packument version information record of the best
     *          satisfactory result.
     */
      std::optional<db::PackumentVInfo>
    resolve( floco::ident_view ident, std::string_view rangeOrTag );


};  /* End class `RegistryDb' */


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
