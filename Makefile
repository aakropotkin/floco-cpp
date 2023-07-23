# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export ROOT_DIR

# ---------------------------------------------------------------------------- #

include mk/config.mk

# ---------------------------------------------------------------------------- #

BINS    = fetch db
LIBS    = libfloco
HEADERS = $(wildcard include/*.hh)
TESTS   = $(wildcard tests/*.cc)


# ---------------------------------------------------------------------------- #

include mk/deps.mk
include mk/lib.mk
include mk/ccls.mk
include mk/clean.mk
include src/Include.mk


# ---------------------------------------------------------------------------- #

.PHONY: bin lib include all clean check tests FORCE
.DEFAULT_GOAL = all


all: bin lib include tests


# ---------------------------------------------------------------------------- #

CXX     ?= c++
MKDIR   ?= mkdir
MKDIR_P ?= $(MKDIR) -p
CP      ?= cp


# ---------------------------------------------------------------------------- #

CXXFLAGS ?=
CXXFLAGS += -Iinclude
CXXFLAGS += $(nix_CFLAGS)

LDFLAGS ?=
LDFLAGS += -Wl,--enable-new-dtags '-Wl,-rpath,$$ORIGIN/../lib'
LDFLAGS += $(nix_LDFLAGS)

CPPFLAGS ?=
LDLIBS   ?=


bin_CPPFLAGS ?=
bin_CXXFLAGS ?=
bin_LDFLAGS  ?= -Llib
bin_LDLIBS   ?=

lib_CPPFLAGS ?=
lib_CXXFLAGS ?= -shared -fPIC
lib_LDFLAGS  ?= -shared -fPIC -Wl,--no-undefined
lib_LDLIBS   ?=


# ---------------------------------------------------------------------------- #

ifneq (,$(DEBUG))
CXXFLAGS += -ggdb3 -pg -fno-omit-frame-pointer
LDFLAGS  += -ggdb3 -pg -fno-omit-frame-pointer
endif


# ---------------------------------------------------------------------------- #

check: FORCE
	@echo TODO


# ---------------------------------------------------------------------------- #

include mk/gen-targets.mk
# This needs to come after we run our templates.
include mk/install.mk


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
