# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

SRC_DIR := $(call getMakefileDir)

include $(SRC_DIR)/util/Include.mk
include $(SRC_DIR)/db/Include.mk
include $(SRC_DIR)/npm/Include.mk
include $(SRC_DIR)/fetch/Include.mk
include $(SRC_DIR)/pdef/Include.mk
include $(SRC_DIR)/inspect/Include.mk

# ---------------------------------------------------------------------------- #

libfloco_LDLIBS += -lsqlite3


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
