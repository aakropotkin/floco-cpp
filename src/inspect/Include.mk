# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(call getMakefileDir)

# ---------------------------------------------------------------------------- #

SRCS          =  $(patsubst %.cc,%.o,$(wildcard $(MAKEFILE_DIR)/*.cc))
libfloco_OBJS += $(filter-out %/main.o,$(SRCS))
inspect_OBJS  += $(MAKEFILE_DIR)/main.o
inspect_LIBS  += libfloco
SRCS          =


# ---------------------------------------------------------------------------- #

$(MAKEFILE_DIR)/inspect.o:   $(addprefix include/floco/,inspect.hh exception.hh)
$(MAKEFILE_DIR)/translate.o: $(addprefix include/,util.hh floco/inspect.hh)
$(MAKEFILE_DIR)/main.o:      $(addprefix include/,pdef.hh floco/inspect.hh)


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
