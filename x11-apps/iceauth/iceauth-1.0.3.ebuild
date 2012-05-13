# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/iceauth/Attic/iceauth-1.0.3.ebuild,v 1.10 2010/01/19 18:13:50 armin76 Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="ICE authority file utility"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris ~x86-winnt"
IUSE=""

SRPM="xorg-x11-server-utils-7.4-15.el6_0.2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libICE"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "unpack failed!"
}
