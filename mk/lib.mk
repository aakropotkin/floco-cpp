# ============================================================================ #
#
# Various helpers and templates used to generate rules.
#
# The caller should evaluate their templates after collecting
# `<TARGET>_OBJS' and `<TARGET>_LIBS' values using:
#
#   $(foreach bin,$(BINS),$(eval $(call BIN_template,$(bin))))
#   $(foreach lib,$(LIBS),$(eval $(call LIB_template,$(lib))))
#   $(ALL_OBJS): %.o: %.cc
#   	$(COMPILE.cc) $< -o $@
#
#   $(BIN_TARGETS) $(LIB_TARGETS):
#   	$(LINK.cc) $^ $(LDLIBS) -o $@
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_LIB

_MK_LIB = 1

# ---------------------------------------------------------------------------- #

MK_DIR ?= $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

include $(MK_DIR)/config.mk


# ---------------------------------------------------------------------------- #

BINS        ?=
BIN_TARGETS ?=
LIBS        ?=  # basenames: `pthread', `floco'
LIB_TARGETS ?=  # fullnames: `libpthread.so`, `libfloco.dylib'
ALL_OBJS    ?=


# ---------------------------------------------------------------------------- #

define BIN_template =
$$(ROOT_DIR)/bin/$(1): CXXFLAGS += $$(bin_CXXFLAGS)
$$(ROOT_DIR)/bin/$(1): LDFLAGS  += $$(bin_LDFLAGS)
$$(ROOT_DIR)/bin/$(1): $$($(1)_OBJS) $$($(1)_LIBS:%=-l%)
ALL_OBJS    += $$($(1)_OBJS)
BIN_TARGETS += $$(ROOT_DIR)/bin/$(1)
.PHONY: bin/$(1)
bin/$(1): $$(ROOT_DIR)/bin/$(1)
endef

# ---------------------------------------------------------------------------- #

define LIB_template =
$$(ROOT_DIR)/lib/$(1)$$(libExt): CXXFLAGS += $$(lib_CXXFLAGS)
$$(ROOT_DIR)/lib/$(1)$$(libExt): LDFLAGS  += $$(lib_LDFLAGS)
$$(ROOT_DIR)/lib/$(1)$$(libExt): $$($(1)_OBJS) $$($(1)_LIBS:%=-l%)
ALL_OBJS    += $$($(1)_OBJS)
LIB_TARGETS += $$(ROOT_DIR)/lib/$(1)$$(libExt)

.PHONY: lib/$(1)$$(libExt) -l$(1:lib%=%)
lib/$(1)$$(libExt) -l$(1:lib%=%): $$(ROOT_DIR)/lib/$(1)$$(libExt)
endef


# ---------------------------------------------------------------------------- #

# Initialize target specific variables.
# The caller should evaluate their templates after collecting
# `<TARGET>_OBJS' and `<TARGET>_LIBS' values.
define TARGET_template =
$(1)_OBJS ::=
$(1)_LIBS ::=
endef

$(foreach t,$(BINS) $(LIBS),$(eval $(call TARGET_template,$(t))))


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_LIB


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
