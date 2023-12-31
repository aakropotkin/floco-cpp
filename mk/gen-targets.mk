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
$(foreach test,$(TESTS),$(eval $(call TEST_template,test_$(test))))

$(ALL_OBJS): %.o: %.cc
	$(COMPILE.cc) $< -o $@

$(BIN_TARGETS) $(LIB_TARGETS) $(TEST_TARGETS):
	$(LINK.cc) $(filter %.o,$^) $(LDLIBS) -o $@


# ---------------------------------------------------------------------------- #

# Detect headers used by each source file and use them to dynamically generate
# Makefile dependency rules.
# This allows rebuilds in development contexts to properly detect modifications.

$(foreach tgt,$(BINS) $(LIBS),$(eval $(call DEPS_template,$(tgt))))
$(foreach tgt,$(BINS) $(LIBS),$(eval -include $$($(tgt)_DEPS_TARGET)))

$(foreach test,$(TESTS),$(eval $(call DEPS_template,test_$(test))))
$(foreach test,$(TEST),$(eval -include $$(test_$(test)_DEPS_TARGET)))


# ---------------------------------------------------------------------------- #

bin:     $(BIN_TARGETS)
lib:     $(LIB_TARGETS)
tests:   $(TEST_TARGETS)
include:
depends: $(DEPEND_TARGETS)


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_GEN_TARGETS


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
