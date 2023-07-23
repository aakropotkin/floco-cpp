# ============================================================================ #
#
# Adds Compilation Database config files to support various
# Language Server Protocol tools.
#
#
# ---------------------------------------------------------------------------- #

ifndef _MK_CCLS

_MK_CCLS = 1

# ---------------------------------------------------------------------------- #

MK_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------- #

include $(MK_DIR)/deps.mk

# ---------------------------------------------------------------------------- #

CAT ?= cat
TR  ?= tr
SED ?= sed


# ---------------------------------------------------------------------------- #

.PHONY: ccls
ccls: $(ROOT_DIR)/.ccls

$(ROOT_DIR)/.ccls: FORCE
	echo 'clang' > "$@";
	{                                                                       \
	  echo "$(CXXFLAGS) $(sqlite3_CFLAGS) $(nljson_CFLAGS) $(nix_CFLAGS)";  \
	  echo "$(argparse_CFLAGS)";                                            \
	  if [[ -n "$(NIX_CC)" ]]; then                                         \
	    $(CAT) "$(NIX_CC)/nix-support/libc-cflags";                         \
	    $(CAT) "$(NIX_CC)/nix-support/libcxx-cxxflags";                     \
	  fi;                                                                   \
	}|$(TR) ' ' '\n'|$(SED) 's/-std=/%cpp -std=/' >> "$@";


# ---------------------------------------------------------------------------- #

endif  # ifndef _MK_CCLS


# ---------------------------------------------------------------------------- #
#
#
#
# ============================================================================ #
