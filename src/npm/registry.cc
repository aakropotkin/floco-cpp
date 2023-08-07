/* ========================================================================== *
 *
 *
 *
 * -------------------------------------------------------------------------- */

#include <cstdio>
#include <filesystem>
#include <string>
#include <list>

#include "floco/exception.hh"
#include "floco/descriptor.hh"
#include "floco-registry.hh"
#include "registry-db.hh"
#include "floco-sql.hh"
#include "semver.hh"


/* -------------------------------------------------------------------------- */

namespace floco {
  namespace registry {

/* -------------------------------------------------------------------------- */

PkgRegistry defaultRegistry = PkgRegistry();


/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getPackumentURL( floco::ident_view ident ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  return s;
}


/* -------------------------------------------------------------------------- */

  std::string
PkgRegistry::getVInfoURL( floco::ident_view   ident
                        , floco::version_view version
                        ) const
{
  std::string s( this->protocol + "://" + this->host + "/" );
  s += ident;
  s += "/";
  s += version;
  return s;
}


/* -------------------------------------------------------------------------- */

  bool
RegistryDb::exists() const
{
  return ( this->_db != nullptr ) || std::filesystem::exists( this->_dbPath );
}


/* -------------------------------------------------------------------------- */

  bool
RegistryDb::create( bool recreate )
{
  bool exists = this->exists();
  if ( exists )
    {
      if ( ! recreate )
        {
          this->_db = std::make_unique<sqlite3pp::database>(
            this->_dbPath.c_str()
          );
          return false;
        }
      if ( this->_db != nullptr ) { this->_db.reset(); }
      std::remove( this->_dbPath.c_str() );
    }
  if ( std::filesystem::path pdir =
         std::filesystem::path( this->_dbPath ).parent_path();
       ! std::filesystem::exists( pdir )
     )
    {
      std::filesystem::create_directories( pdir );
    }
  this->_db = std::make_unique<sqlite3pp::database>( this->_dbPath.c_str() );
  this->_db->execute( pjsCoreSchemaSQL );
  this->_db->execute( packumentsSchemaSQL );
  return true;
}


/* -------------------------------------------------------------------------- */

  std::reference_wrapper<sqlite3pp::database>
RegistryDb::getDb( bool create )
{
  if ( ( ! create ) && ( ! this->exists() ) )
    {
      std::string msg = "no such database: " + this->_dbPath;
      throw sqlite3pp::database_error( msg.c_str() );
    }
  if ( this->_db == nullptr ) { this->create( false ); }
  assert( this->_db != nullptr );
  return std::ref( * this->_db );
}


/* -------------------------------------------------------------------------- */

 db::Packument
RegistryDb::get( floco::ident_view ident )
{
  std::reference_wrapper<sqlite3pp::database> db = this->getDb( true );
  if ( db::db_stale( db, ident ) )
    {
      db::Packument p( (std::string_view) this->getPackumentURL( ident ) );
      p.sqlite3Write( db );
      return p;
    }
  else
    {
      return db::Packument( db, ident );
    }
}


/* -------------------------------------------------------------------------- */

  db::PackumentVInfo
RegistryDb::get( floco::ident_view ident, floco::version_view version )
{
  std::reference_wrapper<sqlite3pp::database> db = this->getDb( true );
  if ( db::db_has( db, ident ) )
    {
      db::Packument p( db, ident );
      if ( auto search = p.versions.find( floco::version( version ) );
           search != p.versions.end()
         )
        {
          return search->second;
        }
    }
  db::Packument p( (std::string_view) this->getPackumentURL( ident ) );
  p.sqlite3Write( db );
  return p.versions.at( (std::string) version );
}


/* -------------------------------------------------------------------------- */

  std::optional<db::PackumentVInfo>
RegistryDb::resolve( floco::ident_view ident, std::string_view rangeOrTag )
{
  bool        isRange;
  std::string desc( rangeOrTag );
  switch ( floco::getDescriptorType( desc.c_str() ) )
    {
      case DT_DIST_TAG:     isRange = false; break;
      case DT_SEMVER_RANGE: isRange = true;  break;
      case DT_NONE: case DT_ERROR:
        {
          std::string msg( "Failed to identify descriptor type or '" );
          msg += ident;
          msg += '@';
          msg += desc;
          msg += "'.";
          throw FlocoException( msg );
        }
        break;
      default:
        {
          std::string msg(
            "Descriptor must be a range or dist-tag, but got '"
          );
          msg += ident;
          msg += '@';
          msg += desc;
          msg += "'.";
          throw FlocoException( msg );
        }
        break;
    }

  db::Packument pack = this->get( ident );
  if ( isRange )
    {
      std::list<std::string> versions;
      for ( const auto & [version, _] : pack.versions )
        {
          versions.emplace_back( version );
        }
      std::list<std::string> sat = semver::semverSat( desc, versions );
      if ( sat.empty() ) { return std::nullopt; }
      return pack.versions.at( sat.back() );
    }
  else
    {
      if ( auto m = pack.distTags.find( desc ); m != pack.distTags.end() )
        {
          return pack.versions.at( m->second );
        }
      else
        {
          return std::nullopt;
        }
    }
}


/* -------------------------------------------------------------------------- */

  }  /* End Namespace `floco::registry' */
}  /* End Namespace `floco' */


/* -------------------------------------------------------------------------- *
 *
 *
 *
 * ========================================================================== */
