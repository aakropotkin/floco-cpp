/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#pragma once

#include <nlohmann/json.hpp>
#include <filesystem>
#include <string>
#include <list>


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

  }  /* End namespace `floco::inspect' */
}  /* End namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
