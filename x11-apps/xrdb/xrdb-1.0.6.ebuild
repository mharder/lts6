# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xrdb/xrdb-1.0.9.ebuild,v 1.7 2011/04/11 17:42:43 xarthisius Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X server resource database utility"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-server-utils-7.4-15.el6_0.2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="x11-libs/libXmu
	x11-libs/libX11"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}

src_prepare() {
	SRPM_PATCHLIST="Patch1101: cve-2011-0465.patch"
	lts6_srpm_epatch || die
}
