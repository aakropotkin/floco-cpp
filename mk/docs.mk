# ============================================================================ #
#
# Provides `docs' target.
#
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_DOCS

_MK_DOCS = 1

# ---------------------------------------------------------------------------- #

DOXYGEN ?= doxygen


# ---------------------------------------------------------------------------- #

.PHONY: docs


# ---------------------------------------------------------------------------- #

docs: docs/index.html

docs/index.html: FORCE
	$(DOXYGEN) ./Doxyfile


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_DOCS


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
