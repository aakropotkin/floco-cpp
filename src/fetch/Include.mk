# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))


# ---------------------------------------------------------------------------- #

libfloco_OBJS := $(MAKEFILE_DIR)/fetch.o
fetch_OBJS    := $(MAKEFILE_DIR)/main.o


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
