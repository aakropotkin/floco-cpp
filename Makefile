# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export ROOT_DIR

# ---------------------------------------------------------------------------- #

include mk/config.mk

# ---------------------------------------------------------------------------- #

BINS    = fetch db
LIBS    = libfloco
HEADERS = $(wildcard include/*.hh)
TESTS   = $(wildcard tests/*.cc)


# ---------------------------------------------------------------------------- #

include mk/deps.mk
include mk/lib.mk
include mk/ccls.mk
include src/Include.mk


# ---------------------------------------------------------------------------- #

.PHONY: bin lib include all clean check tests FORCE
.DEFAULT_GOAL = all


all: bin lib include tests


# ---------------------------------------------------------------------------- #

CXX     ?= c++
MKDIR   ?= mkdir
MKDIR_P ?= $(MKDIR) -p
CP      ?= cp


# ---------------------------------------------------------------------------- #

PREFIX     ?= $(ROOT_DIR)/out
BINDIR     ?= $(PREFIX)/bin
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include


# ---------------------------------------------------------------------------- #

ifndef floco_LDFLAGS
floco_LDFLAGS = -L'$(ROOT_DIR)/lib'
endif  # floco_LDFLAGS


# ---------------------------------------------------------------------------- #

CXXFLAGS ?=
CXXFLAGS += '-I$(ROOT_DIR)/include'
CXXFLAGS += $(nix_CFLAGS)

LDFLAGS ?=
LDFLAGS += -Wl,--enable-new-dtags '-Wl,-rpath,$$ORIGIN/../lib'
LDFLAGS += $(nix_LDFLAGS)

bin_CXXFLAGS ?=
bin_LDFLAGS  ?= $(floco_LDFLAGS)

lib_CXXFLAGS ?= -shared -fPIC
lib_LDFLAGS  ?= -shared -fPIC -Wl,--no-undefined


# ---------------------------------------------------------------------------- #

ifneq (,$(DEBUG))
CXXFLAGS += -ggdb3 -pg -fno-omit-frame-pointer
LDFLAGS  += -ggdb3 -pg -fno-omit-frame-pointer
endif


# ---------------------------------------------------------------------------- #

# Run templates

$(foreach bin,$(BINS),$(eval $(call BIN_template,$(bin))))
$(foreach lib,$(LIBS),$(eval $(call LIB_template,$(lib))))

$(ALL_OBJS): %.o: %.cc
	$(COMPILE.cc) $< -o $@

$(BIN_TARGETS) $(LIB_TARGETS):
	$(LINK.cc) $^ $(LDLIBS) -o $@


# ---------------------------------------------------------------------------- #

include:
bin:     $(BIN_TARGETS)
lib:     $(LIB_TARGETS)


# ---------------------------------------------------------------------------- #

clean: FORCE
	-$(RM) $(BIN_TARGETS)
	-$(RM) $(LIB_TARGETS)
	-$(RM) $(ALL_OBJS)
	-$(RM) result
	-$(RM) -r $(PREFIX)
	-$(RM) *.db gmon.out *.log


# ---------------------------------------------------------------------------- #

.PHONY:  install-dirs install-bin install-lib install-include
install: install-dirs install-bin install-lib install-include

install-dirs: FORCE
	$(MKDIR_P) $(BINDIR) $(LIBDIR) $(INCLUDEDIR)

$(INCLUDEDIR)/%: include/% | install-dirs
	$(MKDIR_P) "$(@D)"
	$(CP) -- "$<" "$@"

$(LIBDIR)/%: lib/% | install-dirs
	$(CP) -- "$<" "$@"

$(BINDIR)/%: bin/% | install-dirs
	$(CP) -- "$<" "$@"

install-bin:     $(patsubst $(ROOT_DIR)/bin/,$(BINDIR)/,$(BIN_TARGETS))
install-lib:     $(patsubst $(ROOT_DIR)/lib/,$(LIBDIR)/,$(LIB_TARGETS))
install-include: $(patsubst include/,$(INCLUDEDIR)/,$(HEADERS))


# ---------------------------------------------------------------------------- #

check: FORCE
	@echo TODO


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
