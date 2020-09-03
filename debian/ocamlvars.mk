include /usr/share/dpkg/architecture.mk

OCAMLMAJOR := 4.11
OCAMLMINOR := 1

OCAML_ABI := $(OCAMLMAJOR).$(OCAMLMINOR)
OCAML_STDLIB_DIR := /usr/lib/ocaml
OCAML_NATIVE_ARCHS := $(shell cat debian/native-archs)
OCAML_OPT_ARCH := $(filter $(DEB_HOST_ARCH),$(OCAML_NATIVE_ARCHS))
OCAML_HAVE_OCAMLOPT := $(if $(OCAML_OPT_ARCH),yes,no)
OCAML_OCAMLDOC_DESTDIR_HTML =
