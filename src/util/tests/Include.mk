# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

ALL_OBJS     += $(MAKEFILE_DIR)/semver.o
TEST_TARGETS += $(MAKEFILE_DIR)/semver

# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/semver.o: include/semver.hh

$(MAKEFILE_DIR)/semver: CPPFLAGS += $(bin_CPPFLAGS)
$(MAKEFILE_DIR)/semver: CXXFLAGS += $(bin_CXXFLAGS)
$(MAKEFILE_DIR)/semver: LDFLAGS  += $(bin_LDFLAGS)
$(MAKEFILE_DIR)/semver: LDFLAGS  += -Wl,-rpath,$(ROOT_DIR)/lib
$(MAKEFILE_DIR)/semver: LDLIBS   += $(bin_LDLIBS)
$(MAKEFILE_DIR)/semver: LDLIBS   += -lfloco
$(MAKEFILE_DIR)/semver: $(MAKEFILE_DIR)/semver.o lib/libfloco$(libExt)
	$(LINK.cc) $(filter %.o,$^) $(LDLIBS) -o $@



# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
