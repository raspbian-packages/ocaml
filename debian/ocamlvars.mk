# Can't use /usr/share/ocaml/ocamlvars.mk because it tries to run ocamlc
OCAML_ABI := $(OCAMLMAJOR).$(OCAMLMINOR)
OCAML_STDLIB_DIR := /usr/lib/ocaml
OCAML_NATIVE_ARCHS := $(shell cat debian/native-archs)
OCAML_NATDYNLINK_ARCHS := $(shell cat debian/natdynlink-archs)
OCAML_OPT_ARCH := $(findstring $(DEB_BUILD_ARCH),$(OCAML_NATIVE_ARCHS))
OCAML_HAVE_OCAMLOPT := $(if $(OCAML_OPT_ARCH),yes,no)
OCAML_OCAMLDOC_DESTDIR_HTML =

ifneq (,$(findstring $(DEB_BUILD_ARCH),$(OCAML_NATDYNLINK_ARCHS)))
  OCAML_NATDYNLINK := yes
else
  OCAML_NATDYNLINK := no
endif
