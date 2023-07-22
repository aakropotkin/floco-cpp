# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

ROOT_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export ROOT_DIR

# ---------------------------------------------------------------------------- #

include mk/deps.mk
include src/Include.mk

# ---------------------------------------------------------------------------- #

MAKEFILE_DIR := $(ROOT_DIR)

# ---------------------------------------------------------------------------- #

.PHONY: bin lib include tests all clean check FORCE
.DEFAULT_GOAL = all


all: bin lib include tests

# ---------------------------------------------------------------------------- #

CXX     ?= c++
RM      ?= rm -f
CAT     ?= cat
UNAME   ?= uname
MKDIR   ?= mkdir
MKDIR_P ?= $(MKDIR) -p
CP      ?= cp
TR      ?= tr
SED     ?= sed


# ---------------------------------------------------------------------------- #

OS ?= $(shell $(UNAME))
OS := $(OS)

ifndef libExt
	ifeq (Linux,$(OS))
		libExt ?= .so
	else
		libExt ?= .dylib
	endif  # ifeq (Linux,$(OS))
endif  # ifndef libExt


# ---------------------------------------------------------------------------- #

PREFIX     ?= $(MAKEFILE_DIR)/out
BINDIR     ?= $(PREFIX)/bin
LIBDIR     ?= $(PREFIX)/lib
INCLUDEDIR ?= $(PREFIX)/include


# ---------------------------------------------------------------------------- #

BINS    = fetch
LIBS    = libfloco
HEADERS = $(wildcard include/*.hh)
TESTS   = $(wildcard tests/*.cc)


# ---------------------------------------------------------------------------- #

ifndef floco_LDFLAGS
	floco_LDFLAGS = -L'$(MAKEFILE_DIR)/lib' -lfloco
endif  # floco_LDFLAGS


# ---------------------------------------------------------------------------- #

CXXFLAGS ?=
CXXFLAGS += '-I$(MAKEFILE_DIR)/include'
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

bin:     $(addprefix bin/,$(BINS))
lib:     $(addsuffix $(libExt),$(addprefix lib/,$(LIBS)))
include:


# ---------------------------------------------------------------------------- #

clean: FORCE
	-$(RM) $(addprefix bin/,$(BINS))
	-$(RM) $(addsuffix $(libExt),$(addprefix lib/,$(LIBS)))
	-$(RM) **/*.o
	-$(RM) result
	-$(RM) -r $(PREFIX)
	#-$(RM) tests/$(TESTS:.cc=)
	-$(RM) *.db gmon.out *.log


# ---------------------------------------------------------------------------- #

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -c "$<"

define genBin =
bin/$(1): lib/libfloco$(libExt)
bin/$(1): CXXFLAGS += $$(bin_CXXFLAGS)
bin/$(1): LDFLAGS  += $$(bin_LDFLAGS)
bin/$(1): $$($(1)_OBJS)
	$$(CXX) $$(CXXFLAGS) $$^ $$(LDFLAGS) -o "$$@"
endef

$(foreach bin,$(BINS),$(eval $(call genBin,$(bin))))


define genLib =
lib/$(1)$(libExt): CXXFLAGS += $$(lib_CXXFLAGS)
lib/$(1)$(libExt): LDFLAGS  += $$(lib_LDFLAGS)
lib/$(1)$(libExt): $$($(1)_OBJS)
	$$(CXX) $$(CXXFLAGS) $$^ $$(LDFLAGS) -o "$$@"
endef

$(foreach lib,$(LIBS),$(eval $(call genLib,$(lib))))


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

install-bin:     $(addprefix $(BINDIR)/,$(BINS))
install-lib:     $(addsuffix $(libExt),$(addprefix $(LIBDIR)/,$(LIBS)))
install-include: $(patsubst include/,$(INCLUDEDIR)/,$(HEADERS))

# ---------------------------------------------------------------------------- #

$(TESTS:.cc=): %: %.cc
	$(CXX) $(CXXFLAGS) $(LDFLAGS) "$<" -o "$@"


check: $(TESTS:.cc=)
	@_ec=0;                     \
	echo '';                    \
	for t in $(TESTS:.cc=); do  \
	  echo "Testing: $$t";      \
	  if "./$$t"; then          \
	    echo "PASS: $$t";       \
	  else                      \
	    _ec=1;                  \
	    echo "FAIL: $$t";       \
	  fi;                       \
	  echo '';                  \
	done;                       \
	exit "$$_ec"


# ---------------------------------------------------------------------------- #

.PHONY: ccls
ccls: .ccls

.ccls: FORCE
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
#
#
#
# ============================================================================ #
