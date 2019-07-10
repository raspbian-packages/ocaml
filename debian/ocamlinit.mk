#
# Description: Useful Makefile rules for OCaml related packages
#
# Copyright © 2009 Stéphane Glondu <steph@glondu.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA.
#

_ocaml_share_path ?= /usr/share/ocaml

ifndef _ocaml_share_ocamlinit
_ocaml_share_ocamlinit = 1

include $(CURDIR)/debian/ocamlvars.mk
include $(_ocaml_share_path)/ocamlvars.mk
-include $(CURDIR)/Makefile.config

# list of .in files contained (non-recursively) in debian/ that requires
# pre-build filling.
# debian/rules writers might need to add stuff to this list:
#  e.g.: OCAML_IN_FILES += debian/patches/foo	# (no .in extension)
OCAML_IN_FILES ?= $(filter-out debian/control,$(patsubst %.in,%,$(wildcard debian/*.in)))

OCAMLINIT_SED := \
  -e 's%@OCamlABI@%$(OCAML_ABI)%g' \
  -e 's%@OCamlStdlibDir@%$(OCAML_STDLIB_DIR)%g' \
  -e 's%@OCamlDllDir@%$(OCAML_DLL_DIR)%g'

# When using these prefixs in *.install.in they must appear in the same order
# as below, with STD: going last since it's processed by gen_modules.pl

ifeq ($(OCAML_HAVE_OCAMLOPT),yes)
  OCAMLINIT_SED += -e 's/^OPT: //' -e '/^BYTE: /d'
else
  OCAMLINIT_SED += -e '/^OPT: /d' -e 's/^BYTE: //'
endif

# Upstream Makefile is mildly buggy, sets NATDYNLINK for sparc64 with no opt
# support. This double-if should stay correct in all future situations.
ifeq ($(OCAML_HAVE_OCAMLOPT) $(NATDYNLINK),yes true)
  OCAMLINIT_SED += -e 's/^DYN: //'
else
  OCAMLINIT_SED += -e '/^DYN: /d'
  OCAMLINIT_SED += -e '/\.cmxs$$/d'
endif

ifeq ($(PROFILING),true)
  OCAMLINIT_SED += -e 's/^PROFILING: //'
else
  OCAMLINIT_SED += -e '/^PROFILING: /d'
endif

otherlib = \
OCAMLINIT_SED += $(if $(filter $(1),$(OTHERLIBRARIES)),\
  -e 's/^OTH: \(.*\b$(1)\.\w\w*$$$$\)/\1/',\
  -e '/^OTH: .*\b$(1)\.\w\w*$$$$/d')
# careful, no whitespace after the comma
$(eval $(call otherlib,raw_spacetime_lib))

ocamlinit: ocamlinit-stamp
ocamlinit-stamp: Makefile.config
	for t in $(OCAML_IN_FILES); do \
	  sed $(OCAMLINIT_SED) $$t.in > $$t; \
	done
	sed -i 's@\./@@' debian/ocaml-nox.lintian-overrides
	touch $@

ocamlinit-clean:
	rm -f ocamlinit-stamp $(OCAML_IN_FILES)

.PHONY: ocamlinit ocamlinit-clean

endif
