# ============================================================================ #
#
# Must be run after evaluating templates.
#
# ---------------------------------------------------------------------------- #

ifndef _MK_INSTALL

_MK_INSTALL = 1

# ---------------------------------------------------------------------------- #

PREFIX     ?= $(ROOT_DIR)/out
BINDIR     ?= $(PREFIX)/bin
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include


# ---------------------------------------------------------------------------- #

include:
bin:     $(BIN_TARGETS)
lib:     $(LIB_TARGETS)


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

endif  # ifndef _MK_INSTALL


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
