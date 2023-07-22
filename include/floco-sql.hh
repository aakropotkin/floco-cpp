static const char pjsCoreSchemaSQL[] = R"SQL(-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '1.0.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS PjsCore (
  name                 TEXT    NOT NULL
, version              TEXT    NOT NULL
, dependencies         JSON    DEFAULT '{}'
, devDependencies      JSON    DEFAULT '{}'
, devDependenciesMeta  JSON    DEFAULT '{}'
, peerDependencies     JSON    DEFAULT '{}'
, peerDependenciesMeta JSON    DEFAULT '{}'
, optionalDependencies JSON    DEFAULT '{}'
, bundledDependencies  JSON    DEFAULT '[]'
, os                   JSON    DEFAULT '["*"]'
, cpu                  JSON    DEFAULT '["*"]'
, engines              JSON    DEFAULT '{}'
, bin                  JSON    DEFAULT NULL
, scripts              JSON    DEFAULT '{}'
, PRIMARY KEY ( name, version )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PjsCoreJSON ( _id, json ) AS
  SELECT ( name || '@' || version ), json_object(
    'name',                 name
  , 'version',              version
  , 'dependencies',         json( dependencies )
  , 'devDependencies',      json( devDependencies )
  , 'devDependenciesMeta',  json( devDependenciesMeta )
  , 'peerDependencies',     json( peerDependencies )
  , 'peerDependenciesMeta', json( peerDependenciesMeta )
  , 'optionalDependencies', json( optionalDependencies )
  , 'bundledDependencies',  json( bundledDependencies )
  , 'os',                   json( os )
  , 'cpu',                  json( cpu )
  , 'engines',              json( engines )
  , 'bin',                  json( bin )
  , 'scripts',              json( scripts )
  ) FROM PjsCore ORDER BY name;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PkgVersions ( name, versions ) AS
  SELECT name, json_group_array( version )
  FROM PjsCore GROUP BY name;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
)SQL";
static const char fetchInfoSchemaSQL[] = R"SQL(-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Tarball(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, safePerms  BOOLEAN
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       t.url
  , 'timestamp', t.timestamp
  , 'safePerms', iif( t.safePersm, json( 'true' ), json( 'false' ) )
  , 'narHash',   t.narHash
  ) FROM Tarball t;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'tarball', 'url', t.url, 'narHash', t.narHash )
FROM Tarball t;


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS File(
  url        TEXT    PRIMARY KEY
, timestamp  INTEGER NOT NULL
, narHash    TEXT
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FileJSON ( url, JSON ) AS
  SELECT url, json_object(
    'url',       f.url
  , 'timestamp', f.timestamp
  , 'narHash',   f.narHash
  ) FROM File f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_FileFetchInfoJSON ( url, fetchInfo ) AS
SELECT url, json_object( 'type', 'file', 'url', f.url, 'narHash', f.narHash )
FROM File f;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TarballFull (
  url, timestamp, safePerms, tarballNarHash, fileNarHash
) AS SELECT t.url, t.timestamp, t.safePerms, t.narHash, f.narHash
FROM Tarball t LEFT JOIN File f ON
( t.url = f.url ) AND ( t.timestamp = f.timestamp )
GROUP BY t.url;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
)SQL";
static const char pdefsSchemaSQL[] = R"SQL(-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS pdefs (
  key      TEXT PRIMARY KEY
, ident    TEXT NOT NULL
, version  TEXT NOT NULL
, ltype    TEXT DEFAULT 'file'

, fetcher    TEXT DEFAULT 'composed'
, fetchInfo  JSON

, lifecycle_build    BOOLEAN
, lifecycle_install  BOOLEAN

, binInfo_binDir    TEXT
, binInfo_binPairs  JSON

, fsInfo_dir         TEXT    DEFAULT '.'
, fsInfo_gypfile     BOOLEAN
, fsInfo_shrinkwrap  BOOLEAN

, sysInfo_cpu  JSON DEFAULT '["*"]'
, sysInfo_os   JSON DEFAULT '["*"]'
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS depInfoEnts (
  parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, runtime    BOOLEAN               NOT NULL
, dev        BOOLEAN DEFAULT TRUE  NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, bundled    BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( parent, ident )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);

CREATE INDEX IF NOT EXISTS depInfoIndex ON depInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS peerInfoEnts (
  parent     TEXT                  NOT NULL
, ident      TEXT                  NOT NULL
, descriptor TEXT    DEFAULT '*'   NOT NULL
, optional   BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( parent, ident )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);

CREATE INDEX IF NOT EXISTS peerInfoIndex ON peerInfoEnts( parent );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS sysInfoEngineEnts(
  parent TEXT NOT NULL
, id     TEXT NOT NULL
, value  JSON NOT NULL
, PRIMARY KEY ( parent, id )
, FOREIGN KEY ( parent ) REFERENCES pdefs ( key )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PdefsJSONV (
  key, ident, version, ltype, fetcher, fetchInfo
, lifecycle, binInfo, depInfo, peerInfo, fsInfo, sysInfo
) AS SELECT
  p.key, p.ident, p.version, p.ltype, p.fetcher, json( p.fetchInfo )
  -- lifecycle
, json_object(
    'build',   iif( p.lifecycle_build,   json( 'true' ), json( 'false' ) )
  , 'install', iif( p.lifecycle_install, json( 'true' ), json( 'false' ) ) )
  -- binInfo
, json_object( 'binDir',   p.binInfo_binDir
             , 'binPairs', json( p.binInfo_binPairs ) )
  -- depInfo
, iif( ( COUNT( di.ident ) <= 0 ), json_object()
     , json_group_object(
         di.ident
       , json_object(
           'descriptor', di.descriptor
         , 'runtime',    iif( di.runtime,  json( 'true' ), json( 'false' ) )
         , 'dev',        iif( di.dev,      json( 'true' ), json( 'false' ) )
         , 'optional',   iif( di.optional, json( 'true' ), json( 'false' ) )
         , 'bundled',    iif( di.bundled,  json( 'true' ), json( 'false' ) )
         ) ) )
  -- peerInfo
, iif( ( COUNT( pi.ident ) <= 0 ), json_object()
     , json_group_object(
         pi.ident
       , json_object(
           'descriptor', pi.descriptor
         , 'optional',   iif( pi.optional, json( 'true' ), json( 'false' ) )
         ) ) )
  -- fsInfo
, json_object(
    'dir',        p.fsInfo_dir
  , 'gypfile',    iif( p.fsInfo_gypfile,    json( 'true' ), json( 'false' ) )
  , 'shrinkwrap', iif( p.fsInfo_shrinkwrap, json( 'true' ), json( 'false' ) ) )
  -- sysInfo
, json_object(
    'cpu',     json( p.sysInfo_cpu )
  , 'os',      json( p.sysInfo_os )
  , 'engines', iif( ( COUNT( sie.id ) <= 0 ), json_object()
                  , json_group_object( sie.id, sie.value )
                  ) )
FROM pdefs p
LEFT JOIN depInfoEnts di        ON ( p.key = di.parent )
LEFT JOIN peerInfoEnts pi       ON ( p.key = pi.parent  )
LEFT JOIN sysInfoEngineEnts sie ON ( p.key = sie.parent )
GROUP BY p.key;


-- -------------------------------------------------------------------------- --

-- SQL -> JSON
-- sqlite3 <DB> 'SELECT JSON from v_PdefsJSONF'|jq [-s];
CREATE VIEW IF NOT EXISTS v_PdefsJSONF ( key, JSON ) AS SELECT key, json_object(
  'key',       p.key
, 'ident',     p.ident
, 'version',   p.version
, 'ltype',     p.ltype
, 'fetcher',   p.fetcher
, 'fetchInfo', json( p.fetchInfo )
, 'lifecycle', json( p.lifecycle )
, 'binInfo',   json( p.binInfo )
, 'depInfo',   json( p.depInfo )
, 'peerInfo',  json( p.peerInfo )
, 'fsInfo',    json( p.fsInfo )
, 'sysInfo',   json( p.sysInfo )
) FROM v_PdefsJSONV p ORDER BY p.key;


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PdefMini(
  key, ltype, lifecycle, binInfo, depInfo, peerInfo
) AS SELECT
  p.key, p.ltype, j.lifecycle
, iif( json_extract( j.binInfo, '$.binPairs' ) = json_object()
     , iif( p.binInfo_binDir = NULL, json_object()
          , json_object( 'binDir', p.binInfo_binDir ) )
     , json_remove( j.binInfo, '$.binDir' ) )
, j.depInfo, j.peerInfo
FROM pdefs p
LEFT JOIN v_PdefsJSONV j ON ( p.key == j.key )
GROUP BY p.key;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
)SQL";
static const char treesSchemaSQL[] = R"SQL(-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '0.1.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS treeInfo(
  treeId   INTEGER PRIMARY KEY
, parent   TEXT                    NOT NULL  -- key
, dev      BOOLEAN DEFAULT TRUE    NOT NULL
, optional BOOLEAN DEFAULT FALSE   NOT NULL
, os       JSON    DEFAULT '["*"]' NOT NULL
, cpu      JSON    DEFAULT '["*"]' NOT NULL
, engines  JSON    DEFAULT '{}'    NOT NULL
);


-- -------------------------------------------------------------------------- --


CREATE TABLE IF NOT EXISTS treeInfoEnts (
  treeId    INTEGER               NOT NULL
, path      TEXT                  NOT NULL
, key       TEXT                  NOT NULL
, dev       BOOLEAN DEFAULT TRUE  NOT NULL
, optional  BOOLEAN DEFAULT FALSE NOT NULL
, link      BOOLEAN DEFAULT FALSE NOT NULL
, PRIMARY KEY ( treeId, path )
, FOREIGN KEY ( treeId ) REFERENCES treeInfo ( treeId )
);


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_TreeEntJSONF ( path, JSON ) AS
SELECT path, json_object(
  'key',      e.key
, 'dev',      iif( e.dev,      json( 'true' ), json( 'false' ) )
, 'optional', iif( e.optional, json( 'true' ), json( 'false' ) )
, 'link',     iif( e.link,     json( 'true' ), json( 'false' ) )
) FROM treeInfoEnts e ORDER BY e.path;


-- -------------------------------------------------------------------------- --

-- SQL -> JSON
-- -----------
-- Just the tree:
--   $ sqlite3 <DB> 'SELECT JSON from v_TreeInfoJSONV'|jq [-s];
--
-- With Info:
--   $ sqlite3 ./ti.db "SELECT json_object( 'id', treeId, 'info', json( info )
--                                        , 'tree', json( JSON ) )
--                      FROM v_TreeInfoJSONV"|jq [-s];
CREATE VIEW IF NOT EXISTS v_TreeInfoJSONV( treeId, info, JSON ) AS SELECT
  t.treeId
, json_object(
    'parent',   t.parent
  , 'dev',      iif( t.dev,      json( 'true' ), json( 'false' ) )
  , 'optional', iif( t.optional, json( 'true' ), json( 'false' ) )
  , 'os',       json( t.os )
  , 'cpu',      json( t.cpu )
  , 'engines',  json( t.engines )
  )
, json_group_object( e.path, (
  SELECT json( JSON ) FROM v_TreeEntJSONF ej
  WHERE e.path = ej.path
  ORDER BY ej.path
) ) FROM treeInfo t
    LEFT JOIN treeInfoEnts e
    ON t.treeId = e.treeId
    GROUP BY t.treeId;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
)SQL";
static const char packumentsSchemaSQL[] = R"SQL(-- ========================================================================== --
--
--
--
-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS SchemaVersion( version TEXT NOT NULL );
INSERT OR IGNORE INTO SchemaVersion ( version ) VALUES ( '1.0.0' );


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS Packument (
  _id        TEXT  NOT NULL              -- `<name>'
, _rev       TEXT  NOT NULL DEFAULT '0'
, name       TEXT  NOT NULL
, time       JSON  DEFAULT '{}'
, distTags   JSON  DEFAULT '{}'
, PRIMARY KEY ( _id, _rev )
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS VInfo (
  _id             TEXT NOT NULL  PRIMARY KEY  -- `<name>@<version>'
, homepage        TEXT
, description     TEXT
, license         TEXT
, repository      JSON
, dist            JSON
, _hasShrinkwrap  BOOLEAN DEFAULT false
);


-- -------------------------------------------------------------------------- --

CREATE TABLE IF NOT EXISTS PackumentVInfo (
  _id       TEXT     NOT NULL  PRIMARY KEY  -- `<name>@<version>'
, time      INTEGER  NOT NULL
, distTags  JSON     DEFAULT '[]'
);


-- -------------------------------------------------------------------------- --

-- NOTE: `json_patch' omits `{ "foo": null }' fields in its second argument.
--       With this in mind we must make any nullable fields part of the first
--       argument instead.
--       We can "get away with" only declaring nullable fields from `VInfo' here
--       only because `null' is not a valid value for any `PjsCore' fields.
CREATE VIEW IF NOT EXISTS v_VInfoJSON ( _id, json ) AS
  SELECT v._id, json_patch( json_object(
    'homepage',       iif( v.homepage    = NULL, json( 'null' ), v.homepage )
  , 'description',    iif( v.description = NULL, json( 'null' ), v.description )
  , 'license',        iif( v.license     = NULL, json( 'null' ), v.license )
  , 'repository',     json( iif( v.repository  = NULL, 'null', v.repository ) )
  , 'dist',           json( iif( v.dist        = NULL, 'null', v.dist ) )
  , '_hasShrinkWrap', iif( v._hasShrinkwrap, json( 'true' ), json( 'false' ) )
  ), json( p.json ) )
  FROM VInfo v LEFT JOIN v_PjsCoreJSON p ON ( v._id = p._id );


-- -------------------------------------------------------------------------- --

CREATE VIEW IF NOT EXISTS v_PackumentJSON ( _id, json ) AS
  SELECT p._id, json_object(
    '_id',        p._id
  , '_rev',       p._rev
  , 'name',       iif( p.name = NULL, p._id, p.name )
  , 'time',       json( p.time )
  , 'dist-tags',  json( p.distTags )
  , 'versions',   json_group_object( json_extract( vi.json, '$.version' )
                                   , json( vi.json ) )
  )
  FROM Packument p
  LEFT JOIN v_VInfoJSON vi ON ( p._id = json_extract( vi.json, '$.name' ) )
  GROUP BY p._id;


-- -------------------------------------------------------------------------- --
--
--
--
-- ========================================================================== --
)SQL";
