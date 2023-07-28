# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

TESTS += semver resolve


# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/semver.o: include/semver.hh

test_semver_TARGET := $(MAKEFILE_DIR)/semver
test_semver_OBJS   := $(MAKEFILE_DIR)/semver.o


# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/semver.o: $(addprefix include/,semver.hh registry-db.hh)

test_resolve_TARGET := $(MAKEFILE_DIR)/resolve
test_resolve_OBJS   := $(MAKEFILE_DIR)/resolve.o


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
