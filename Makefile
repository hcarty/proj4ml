OCAMLMAKEFILE = OCamlMakefile
ANNOTATE = yes
PACKS = 
LIBS =
OCAMLLIBPATH=
INCDIRS=
LIBDIRS=
EXTLIBDIRS=

CLIBS = proj m
CFLAGS = -g

# We turn on debugger support in all our modules for now.
OCAMLBCFLAGS =
OCAMLBLDFLAGS =
RESULT = proj4

SOURCES = proj4.mli proj4.ml proj4_stubs.c

# Installation settings
LIBINSTALL_FILES = *.mli *.cmi *.cma *.cmxa *.a *.so

all: byte-code-library native-code-library top

mrproper: clean
	rm -f *~ *.cmi *.cmo *.top *.so

.PHONY: mrproper

test: all
	prove t/*.ml

install: libinstall

uninstall: libuninstall

include $(OCAMLMAKEFILE)
