/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <list>
#include <string>
#include <unordered_map>
#include <optional>
#include <nlohmann/json.hpp>
#include <sqlite3pp.hh>

#include "pjs-core.hh"


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

class BinInfo {

  private:
    void init( const nlohmann::json & j );

  public:

    std::optional<std::string>                                  binDir;
    std::optional<std::unordered_map<std::string, std::string>> binPairs;

    BinInfo() = default;

    explicit BinInfo( const nlohmann::json & j ) { this->init( j ); }

    BinInfo( std::string_view binDir ) : binDir( binDir ) {}

    BinInfo( floco::ident_view ident, std::string_view path )
      : binDir( path.ends_with( ".js" ) ? std::nullopt
                                        : std::make_optional( path )
              )
      , binPairs(
          path.ends_with( ".js" )
          ? std::make_optional( (std::unordered_map<std::string, std::string>) {
              { std::string( ident ), std::string( path ) }
            } )
          : std::nullopt
        )
    {}

    BinInfo(
      const std::unordered_map<std::string, std::string> & binPairs
    ) : binPairs( binPairs )
    {}

    BinInfo( sqlite3pp::database & db
           , floco::ident_view     parent_ident
           , floco::version_view   parent_version
           );

    BinInfo( const PjsCore & pjs ) { ( * this ) = pjs; }

    BinInfo & operator=( const PjsCore & pjs );

    void sqlite3Write( sqlite3pp::database & db
                     , floco::ident_view     parent_ident
                     , floco::version_view   parent_version
                     ) const;

    nlohmann::json toJSON() const;

    void reset() { this->binDir = std::nullopt; this->binPairs = std::nullopt; }

    friend void from_json( const nlohmann::json & j, BinInfo & e );
    friend class PjsCore;

};  /* End class `BinInfo' */


/* `BinInfo' <--> JSON */
void to_json(         nlohmann::json & j, const BinInfo & e );
void from_json( const nlohmann::json & j,       BinInfo & e );


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
