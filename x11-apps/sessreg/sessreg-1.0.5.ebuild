# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/sessreg/sessreg-1.0.7.ebuild,v 1.8 2012/03/03 16:25:22 ranger Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="manage utmp/wtmp entries for non-init clients"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE=""

SRPM="xorg-x11-server-utils-7.4-15.el6_0.2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}
