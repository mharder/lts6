# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.20.1-r1.ebuild,v 1.14 2011/09/22 17:29:31 vapier Exp $

PATCHVER="1.0"
ELF2FLT_VER=""
BINUTILS_TYPE="srpm"
BINUTILS_VER="2.20.51"
SRPM="binutils-2.20.51.0.2-5.20.el6_1.1.src.rpm"
inherit lts6-toolchain-binutils

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
