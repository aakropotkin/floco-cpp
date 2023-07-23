# ============================================================================ #
#
# Set `<DEP>_(CFLAGS|LDFLAGS|*)' style variables.
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_DEPS

_MK_DEPS = 1

# ---------------------------------------------------------------------------- #

PKG_CONFIG ?= pkg-config
NIX        ?= nix
JQ         ?= jq

FLAKE_LOCK ?= $(ROOT_DIR)/flake.lock


# ---------------------------------------------------------------------------- #

getLockedRev =  $(shell $(JQ) -r '.nodes["$1"].locked.rev' $(FLAKE_LOCK))

NIXPKGS_REF ?= github:NixOS/nixpkgs/$(call getLockedRev,nixpkgs)
NIXPKGS_REF := $(NIXPKGS_REF)


# ---------------------------------------------------------------------------- #

getNixOutpath = $(shell $(NIX) build --no-link --print-out-paths $1)


# ---------------------------------------------------------------------------- #

nljson_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags nlohmann_json)
nljson_CFLAGS := $(nljson_CFLAGS)


# ---------------------------------------------------------------------------- #

argparse_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags argparse)
argparse_CFLAGS := $(argparse_CFLAGS)


# ---------------------------------------------------------------------------- #

boost_CFLAGS ?= -I$(call getNixOutpath,'$(NIXPKGS_REF)#boost.dev')/include
boost_CFLAGS := $(boost_CFLAGS)


# ---------------------------------------------------------------------------- #

sqlite3_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags sqlite3)
sqlite3_CFLAGS := $(sqlite3_CFLAGS)

sqlite3_LDFLAGS ?= $(shell $(PKG_CONFIG) --libs sqlite3)
sqlite3_LDFLAGS := $(sqlite3_LDFLAGS)
.PHONY: -lsqlite3


# ---------------------------------------------------------------------------- #

ifndef nix_CFLAGS
nix_INCDIR ?= $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)
nix_INCDIR := $(nix_INCDIR)

nix_CFLAGS =  $(boost_CFLAGS)
nix_CFLAGS += $(shell $(PKG_CONFIG) --cflags nix-main nix-cmd nix-expr)
nix_CFLAGS += -isystem '$(nix_INCDIR)'
nix_CFLAGS += -include $(nix_INCDIR)/nix/config.h
endif  # ifndef nix_CFLAGS
nix_CFLAGS := $(nix_CFLAGS)

ifndef nix_LDFLAGS
nix_LDFLAGS =                                                        \
  $(shell $(PKG_CONFIG) --libs nix-main nix-cmd nix-expr nix-store)
nix_LDFLAGS += -lnixfetchers
endif  # infndef nix_LDFLAGS
nix_LDFLAGS := $(nix_LDFLAGS)
.PHONY: -lnix-main -lnix-cmd -lnix-exp -lnix-store


# ---------------------------------------------------------------------------- #

endif  # ifndep _MK_DEPS


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
