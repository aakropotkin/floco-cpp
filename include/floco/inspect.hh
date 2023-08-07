/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <filesystem>
#include <string>
#include <list>
#include <unordered_map>
#include <functional>
#include <nlohmann/json.hpp>

#include "pdef.hh"
#include "registry-db.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace inspect {

/* -------------------------------------------------------------------------- */

bool hasPackageJSON( const std::filesystem::path & tree );
bool hasPackageLock( const std::filesystem::path & tree );
bool hasYarnLock(    const std::filesystem::path & tree );
bool hasShrinkwrap(  const std::filesystem::path & tree );
bool hasGypfile(     const std::filesystem::path & tree );
bool hasNmDir(       const std::filesystem::path & tree );


/* -------------------------------------------------------------------------- */

nlohmann::json getPackageJSON( const std::filesystem::path & tree );
nlohmann::json getPackageLock( const std::filesystem::path & tree );
//nlohmann::json getYarnLock(    const std::filesystem::path & tree );
nlohmann::json getShrinkwrap(  const std::filesystem::path & tree );

std::list<std::string> getBinPaths( const std::filesystem::path & tree );
std::list<std::string> getBinPaths( const std::filesystem::path & tree
                                  , const nlohmann::json        & pjs
                                  );


/* -------------------------------------------------------------------------- */

/**
 * Create a `pdef` record for a single package.
 * @param treeURL A fetchable URL containing a `package.json` file.
 * @return A translated `PdefCore` record.
 */
PdefCore translateOne( std::string_view treeURL );


/* -------------------------------------------------------------------------- */

/**
 * A hashmap with a `{ <IDENT>: { <VERSION>: <PDEF>, ... }, ... }` hierarchy.
 */
using NameVersionCollection =
  std::unordered_map< floco::ident
                    , std::unordered_map<floco::version, PdefCore>
                    >;
using NvKey = std::pair<floco::ident, floco::version>;

  std::pair<NvKey, NameVersionCollection>
translate( registry::RegistryDb & registry, std::string_view treeURL );


/* -------------------------------------------------------------------------- */

  }  /* End namespace `floco::inspect' */
}  /* End namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
