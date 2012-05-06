# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/util-macros/util-macros-1.14.0.ebuild,v 1.2 2011/06/19 08:30:31 chithanh Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org autotools utility macros"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-util-macros-1.14.0-2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: util-macros-1.14.0-autoconf-compat.patch"
	lts6_srpm_epatch || die
}
