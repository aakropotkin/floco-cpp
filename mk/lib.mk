# ============================================================================ #
#
# Various helpers and templates used to generate rules.
#
# The caller should evaluate their templates after collecting
# `<TARGET>_OBJS' and `<TARGET>_LIBS' values using:
#
#   include mk/gen-target.mk
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_LIB

_MK_LIB = 1

# ---------------------------------------------------------------------------- #

TEST_TARGETS ?=
TESTS        ?=
BINS         ?=
BIN_TARGETS  ?=
LIBS         ?=  # basenames: `pthread', `floco'
LIB_TARGETS  ?=  # fullnames: `libpthread.so`, `libfloco.dylib'
ALL_OBJS     ?=


# ---------------------------------------------------------------------------- #

.PHONY: bin lib include FORCE


# ---------------------------------------------------------------------------- #

ifndef MK_DIR
MK_DIR :=                                                                    \
  $(patsubst $(CURDIR)/%/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
endif  # ifndef MK_DIR

include $(MK_DIR)/config.mk


# ---------------------------------------------------------------------------- #

define getCanonicalPath
$(patsubst $(CURDIR)/%,%,$(abspath $(1)))
endef

define getMakefileDir
$(patsubst $(CURDIR)/%/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
endef

define getMakefileAbsDir
$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
endef


# ---------------------------------------------------------------------------- #

define BIN_template =
$(1)_TARGET ?= bin/$(1)
$$($(1)_TARGET): CPPFLAGS += $$(bin_CPPFLAGS) $$($(1)_CXXFLAGS)
$$($(1)_TARGET): CXXFLAGS += $$(bin_CXXFLAGS) $$($(1)_CXXFLAGS)
$$($(1)_TARGET): LDFLAGS  += $$(bin_LDFLAGS)  $$($(1)_LDFLAGS)
$$($(1)_TARGET): LDLIBS   += $$(bin_LDLIBS)   $$($(1)_LDLIBS)
$$($(1)_TARGET): LDLIBS   += $$($(1)_LIBS:lib%=-l%)
$$($(1)_TARGET): $$($(1)_OBJS) $$($(1)_LIBS:%=lib/%$$(libExt))
ALL_OBJS    += $$($(1)_OBJS)
BIN_TARGETS += $$($(1)_TARGET)
endef


# ---------------------------------------------------------------------------- #

define LIB_template =
$(1)_TARGET ?= lib/$(1)$$(libExt)
$$($(1)_TARGET): CPPFLAGS += $$(lib_CPPFLAGS) $$($(1)_CPPFLAGS)
$$($(1)_TARGET): CXXFLAGS += $$(lib_CXXFLAGS) $$($(1)_CXXFLAGS)
$$($(1)_TARGET): LDFLAGS  += $$(lib_LDFLAGS)  $$($(1)_LDFLAGS)
$$($(1)_TARGET): LDLIBS   += $$(lib_LDLIBS)   $$($(1)_LDLIBS)
$$($(1)_TARGET): LDLIBS   += $$($(1)_LIBS:lib%=-l%)
$$($(1)_TARGET): $$($(1)_OBJS) $$($(1)_LIBS:%=lib/%$$(libExt))
ALL_OBJS    += $$($(1)_OBJS)
LIB_TARGETS += $$($(1)_TARGET)
endef


# ---------------------------------------------------------------------------- #

# Initialize target specific variables.
# The caller should evaluate their templates after collecting
# `<TARGET>_OBJS' and `<TARGET>_LIBS' values.
define TARGET_template =
$(1)_OBJS     ::=
$(1)_LIBS     ::=
$(1)_LDFLAGS  ::=
$(1)_LDLIBS   ::=
$(1)_CXXFLAGS ::=
$(1)_CPPFLAGS ::=
endef

$(foreach t,$(BINS) $(LIBS),$(eval $(call TARGET_template,$(t))))


# ---------------------------------------------------------------------------- #

define TEST_template =
$(1)_LIBS   ?= libfloco
$(1)_TARGET ?= $(1:test_%=%)
$$($(1)_TARGET): CPPFLAGS += $$(bin_CPPFLAGS) $$($(1)_CPPFLAGS)
$$($(1)_TARGET): CXXFLAGS += $$(bin_CXXFLAGS) $$($(1)_CXXFLAGS)
$$($(1)_TARGET): LDFLAGS  += $$(bin_LDFLAGS)  $$($(1)_LDFLAGS)
$$($(1)_TARGET): LDLIBS   += $$(bin_LDLIBS)   $$($(1)_LDLIBS)
$$($(1)_TARGET): LDLIBS   += $$($(1)_LIBS:lib%=-l%)
$$($(1)_TARGET): LDFLAGS  += -Wl,-rpath,$(ROOT_DIR)/lib
$$($(1)_TARGET): $$($(1)_OBJS) $$($(1)_LIBS:%=lib/%$$(libExt))
ALL_OBJS     += $$($(1)_OBJS)
TEST_TARGETS += $$($(1)_TARGET)
endef


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_LIB


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
