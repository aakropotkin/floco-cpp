# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

libfloco_OBJS += $(patsubst %.cc,%.o,$(wildcard $(MAKEFILE_DIR)/*.cc))


# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/pdef.o:                                          \
  $(addprefix include/,pdef.hh floco/exception.hh floco-sql.hh)

$(MAKEFILE_DIR)/dep-info.o:  include/pdef/dep-info.hh
$(MAKEFILE_DIR)/peer-info.o: include/pdef/peer-info.hh
$(MAKEFILE_DIR)/sys-info.o:  include/pdef/sys-info.hh
$(MAKEFILE_DIR)/bin-info.o:  include/pdef/bin-info.hh


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
