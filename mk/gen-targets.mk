# ============================================================================ #
#
# Evaluates target recipes defined by `./lib.mk'.
# This should be run after collecting `<TARGET>_(OBJ|LIB)S' values.
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_GEN_TARGETS

_MK_GEN_TARGETS = 1

# ---------------------------------------------------------------------------- #

# Run templates.

$(foreach bin,$(BINS),$(eval $(call BIN_template,$(bin))))
$(foreach lib,$(LIBS),$(eval $(call LIB_template,$(lib))))

$(ALL_OBJS): %.o: %.cc
	$(COMPILE.cc) $< -o $@

$(BIN_TARGETS) $(LIB_TARGETS):
	$(LINK.cc) $(filter %.o,$^) $(LDLIBS) -o $@


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_GEN_TARGETS


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
