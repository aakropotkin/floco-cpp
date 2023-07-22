# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

include mk/deps.mk

# ---------------------------------------------------------------------------- #

MAKEFILE_DIR = $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------- #

.PHONY: all clean FORCE
.DEFAULT_GOAL = all


# ---------------------------------------------------------------------------- #

CXX        ?= c++
RM         ?= rm -f
CAT        ?= cat
UNAME      ?= uname
MKDIR      ?= mkdir
MKDIR_P    ?= $(MKDIR) -p
CP         ?= cp
TR         ?= tr
SED        ?= sed


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

BINS  =  
LIBS  =  
TESTS = $(wildcard tests/*.cc)


# ---------------------------------------------------------------------------- #

CXXFLAGS ?=
LDFLAGS  ?=


CXXFLAGS += -I$(MAKEFILE_DIR)/include

lib_CXXFLAGS ?= -shared -fPIC
lib_LDFLAGS  ?= -shared -fPIC -Wl,--no-undefined


# ---------------------------------------------------------------------------- #

ifneq (,$(DEBUG))
	CXXFLAGS += -ggdb3 -pg -fno-omit-frame-pointer
	LDFLAGS  += -ggdb3 -pg -fno-omit-frame-pointer
endif


# ---------------------------------------------------------------------------- #

.PHONY: bin lib include

bin: $(addprefix bin/,$(BINS))
lib: $(addprefix lib/,$(LIBS))
include:


# ---------------------------------------------------------------------------- #

clean: FORCE
	-$(RM) $(addprefix bin/,$(BINS))
	-$(RM) $(addprefix lib/,$(LIBS))
	-$(RM) **/*.o
	-$(RM) result
	-$(RM) -r $(PREFIX)
	-$(RM) tests/$(TESTS:.cc=)
	-$(RM) *.db gmon.out *.log


# ---------------------------------------------------------------------------- #

%.o: %.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -c "$<"


# ---------------------------------------------------------------------------- #

.PHONY: install-dirs install-bin install-lib install-include install
install: install-dirs install-bin install-lib install-include

install-dirs: FORCE
	$(MKDIR_P) $(BINDIR) $(LIBDIR) $(INCLUDEDIR)/pdef

$(INCLUDEDIR)/%: include/% | install-dirs
	$(CP) -- "$<" "$@"

$(LIBDIR)/%: lib/% | install-dirs
	$(CP) -- "$<" "$@"

$(BINDIR)/%: bin/% | install-dirs
	$(CP) -- "$<" "$@"

install-bin: $(addprefix $(BINDIR)/,$(BINS))
install-lib: $(addprefix $(LIBDIR)/,$(LIBS))
install-include: $(patsubst include/,$(INCLUDEDIR)/,$(wildcard include/*.hh))


# ---------------------------------------------------------------------------- #

.PHONY: tests check

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

all: bin lib tests


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
