# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

libfloco_OBJS += $(patsubst %.cc,%.o,$(wildcard $(MAKEFILE_DIR)/*.cc))


# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/pjs-core.o:                                        \
  $(addprefix include/,fetch.hh sqlite3pp.h sqlite3pp.ipp util.hh  \
                       floco-registry.hh pjs-core.hh)

$(MAKEFILE_DIR)/vinfo.o:                                     \
  $(addprefix include/,fetch.hh floco-registry.hh vinfo.hh)

$(MAKEFILE_DIR)/registry.o:                                               \
  $(addprefix include/,floco-registry.hh registry-db.hh floco-sql.hh      \
                       semver.hh floco/exception.hh floco/descriptor.hh)

$(MAKEFILE_DIR)/pjs-core.o:                                        \
  $(addprefix include/,fetch.hh date.hh util.hh floco-registry.hh  \
                       packument.hh)


# ---------------------------------------------------------------------------- #

include $(MAKEFILE_DIR)/tests/Include.mk


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
