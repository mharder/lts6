# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/evieext/evieext-1.1.1.ebuild,v 1.7 2011/04/16 18:10:33 armin76 Exp $

EAPI="4"

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org EvIE protocol headers"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRPM="xorg-x11-proto-devel-7.6-13.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}
