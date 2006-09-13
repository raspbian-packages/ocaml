# -*- mode: makefile; coding: utf-8 -*-
# Copyright © 2003 Colin Walters <walters@debian.org> and Jonas
# Smedegaard <dr@jones.dk>
# Description: Defines useful variables for Perl modules
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
# 02111-1307 USA.

_cdbs_scripts_path ?= /usr/lib/cdbs
_cdbs_rules_path ?= /usr/share/cdbs/1/rules
_cdbs_class_path ?= /usr/share/cdbs/1/class

ifndef _cdbs_class_perlmodule_vars
_cdbs_class_perlmodule_vars = 1

include $(_cdbs_class_path)/makefile-vars.mk$(_cdbs_makefile_suffix)

# Override optimizations to follow Perl Policy 3.3
DEB_MAKE_INVOKE = $(DEB_MAKE_ENVVARS) $(MAKE) -C $(DEB_BUILDDIR) OPTIMIZE="$(CFLAGS)"

# Install into first listed package by default.
# Unset for standard debhelper rules (use debian/tmp if multiple packages).
DEB_MAKEMAKER_PACKAGE := $(firstword $(shell $(_cdbs_scripts_path)/list-packages))

DEB_MAKEMAKER_INVOKE = /usr/bin/perl Makefile.PL INSTALLDIRS=vendor

# Set some MakeMaker defaults
DEB_MAKE_BUILD_TARGET = all
DEB_MAKE_CLEAN_TARGET = distclean
DEB_MAKE_CHECK_TARGET = test
DEB_MAKE_INSTALL_TARGET = install PREFIX=$(if $(DEB_MAKEMAKER_PACKAGE),$(CURDIR)/debian/$(DEB_MAKEMAKER_PACKAGE)/usr,$(DEB_DESTDIR)/usr)

endif
