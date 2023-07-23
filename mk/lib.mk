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

BINS        ?=
BIN_TARGETS ?=
LIBS        ?=  # basenames: `pthread', `floco'
LIB_TARGETS ?=  # fullnames: `libpthread.so`, `libfloco.dylib'
ALL_OBJS    ?=


# ---------------------------------------------------------------------------- #

define BIN_template =
bin/$(1): CPPFLAGS += $$(bin_CPPFLAGS) $$($(1)_CXXFLAGS)
bin/$(1): CXXFLAGS += $$(bin_CXXFLAGS) $$($(1)_CXXFLAGS)
bin/$(1): LDFLAGS  += $$(bin_LDFLAGS)  $$($(1)_LDFLAGS)
bin/$(1): LDLIBS   += $$(bin_LDLIBS)   $$($(1)_LDLIBS)
bin/$(1): LDLIBS   += $$($(1)_LIBS:lib%=-l%)
bin/$(1): $$($(1)_OBJS) $$($(1)_LIBS:%=lib/%$$(libExt))
ALL_OBJS    += $$($(1)_OBJS)
BIN_TARGETS += bin/$(1)
endef

# ---------------------------------------------------------------------------- #

define LIB_template =
lib/$(1)$$(libExt): CPPFLAGS += $$(lib_CPPFLAGS) $$($(1)_CPPFLAGS)
lib/$(1)$$(libExt): CXXFLAGS += $$(lib_CXXFLAGS) $$($(1)_CXXFLAGS)
lib/$(1)$$(libExt): LDFLAGS  += $$(lib_LDFLAGS)  $$($(1)_LDFLAGS)
lib/$(1)$$(libExt): LDLIBS   += $$(lib_LDLIBS)   $$($(1)_LDLIBS)
lib/$(1)$$(libExt): LDLIBS   += $$($(1)_LIBS:lib%=-l%)
lib/$(1)$$(libExt): $$($(1)_OBJS) $$($(1)_LIBS:%=lib/%$$(libExt))
ALL_OBJS    += $$($(1)_OBJS)
LIB_TARGETS += lib/$(1)$$(libExt)
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

endif  # ifndef _MK_LIB


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
