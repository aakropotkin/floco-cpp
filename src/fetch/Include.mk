# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

libfloco_OBJS += $(MAKEFILE_DIR)/fetch.o
fetch_OBJS    += $(MAKEFILE_DIR)/main.o
fetch_LIBS    += libfloco


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
