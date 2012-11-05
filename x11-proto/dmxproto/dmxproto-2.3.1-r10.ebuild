# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/dmxproto/dmxproto-2.3.1.ebuild,v 1.8 2012/05/11 02:59:23 aballier Exp $

EAPI="4"

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org DMX protocol headers"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE=""

SRPM="xorg-x11-proto-devel-7.6-13.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="!<x11-libs/libdmx-1.0.99.1"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}
