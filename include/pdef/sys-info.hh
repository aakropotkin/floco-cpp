/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <list>
#include <nlohmann/json.hpp>
#include <string>
#include "sqlite3pp.h"
#include "pjs-core.hh"
#include <unordered_map>


/* -------------------------------------------------------------------------- */

namespace floco {

/* -------------------------------------------------------------------------- */

class SysInfo {

  private:
    void init( const nlohmann::json & j );

  public:

    std::list<std::string>                                  cpu     = { "*" };
    std::list<std::string>                                  os      = { "*" };
    std::unordered_map<std::string, std::list<std::string>> engines;

    SysInfo() = default;

    explicit SysInfo( const nlohmann::json & j ) { this->init( j ); }

    SysInfo( sqlite3pp::database & db
           , floco::ident_view     parent_ident
           , floco::version_view   parent_version
           );

    SysInfo( const PjsCore &  pjs );
    SysInfo(       PjsCore && pjs );

    SysInfo & operator=( const PjsCore &  pjs );
    SysInfo & operator=(       PjsCore && pjs );

    void sqlite3WriteEngines( sqlite3pp::database & db
                            , floco::ident_view     parent_ident
                            , floco::version_view   parent_version
                            ) const;
    void sqlite3WriteCore( sqlite3pp::database & db
                         , floco::ident_view     parent_ident
                         , floco::version_view   parent_version
                         ) const;

    nlohmann::json toJSON() const;

    void reset() { this->cpu = {}; this->os = {}; this->engines = {}; }

    friend void from_json( const nlohmann::json & j, SysInfo & e );
    friend class PjsCore;

};  /* End class `SysInfo' */


/* `SysInfo' <--> JSON */
void to_json(         nlohmann::json & j, const SysInfo & e );
void from_json( const nlohmann::json & j,       SysInfo & e );


/* -------------------------------------------------------------------------- */

}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
