# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xf86bigfontproto/xf86bigfontproto-1.2.0.ebuild,v 1.13 2012/04/26 18:34:26 aballier Exp $

EAPI="4"
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org XF86BigFont protocol headers"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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
