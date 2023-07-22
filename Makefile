# ============================================================================ #
#
#
#
# ---------------------------------------------------------------------------- #

MAKEFILE_DIR ?= $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------- #

.PHONY: all clean FORCE
.DEFAULT_GOAL = all


# ---------------------------------------------------------------------------- #

CXX        ?= c++
RM         ?= rm -f
CAT        ?= cat
PKG_CONFIG ?= pkg-config
NIX        ?= nix
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
TESTS =  $(wildcard tests/*.cc)


# ---------------------------------------------------------------------------- #

CXXFLAGS ?=
CXXFLAGS += -I$(MAKEFILE_DIR)/include

lib_CXXFLAGS = -shared -fPIC
lib_LDFLAGS  = -shared -fPIC -Wl,--no-undefined


nljson_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags nlohmann_json)
nljson_CFLAGS := $(nljson_CFLAGS)

argparse_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags argparse)
argparse_CFLAGS := $(argparse_CFLAGS)

boost_CFLAGS ?=                                                                \
  -I$(shell $(NIX) build --no-link --print-out-paths 'nixpkgs#boost')/include
boost_CFLAGS := $(boost_CFLAGS)

sqlite3_CFLAGS ?= $(shell $(PKG_CONFIG) --cflags sqlite3)
sqlite3_CFLAGS := $(sqlite3_CFLAGS)

sqlite3_LDFLAGS ?= $(shell $(PKG_CONFIG) --libs sqlite3)
sqlite3_LDFLAGS := $(sqlite3_LDFLAGS)

ifndef nix_CFLAGS
	nix_CFLAGS =  $(boost_CFLAGS)
	nix_CFLAGS += $(shell $(PKG_CONFIG) --cflags nix-main nix-cmd nix-expr)
	nix_CFLAGS += -isystem $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)
	nix_CFLAGS +=                                                                 \
	  -include $(shell $(PKG_CONFIG) --variable=includedir nix-cmd)/nix/config.h
endif
nix_CFLAGS := $(nix_CFLAGS)

ifndef nix_LDFLAGS
	nix_LDFLAGS =                                                        \
	  $(shell $(PKG_CONFIG) --libs nix-main nix-cmd nix-expr nix-store)
  nix_LDFLAGS += -lnixfetchers
endif

##flocodb_LDFLAGS =  '-L$(MAKEFILE_DIR)/lib' -lflocodb
##flocodb_LDFLAGS += -Wl,--enable-new-dtags '-Wl,-rpath,$$ORIGIN/../lib'


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
install-include: $(addprefix $(INCLUDEDIR)/,$(GEN_HEADERS))
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
ccls: ../../.ccls

../../.ccls: FORCE
	echo 'clang' > "$@";
	{                                                                       \
	  echo "$(CXXFLAGS) $(sqlite3_CFLAGS) $(nljson_CFLAGS) $(nix_CFLAGS)";  \
	  echo "$(argparse_CFLAGS) $(boost_CFLAGS)";                            \
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
