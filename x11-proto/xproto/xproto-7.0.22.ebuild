# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xproto/xproto-7.0.22.ebuild,v 1.7 2011/10/03 18:09:13 josejx Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org xproto protocol headers"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-proto-devel-7.6-13.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}

pkg_setup() {
	xorg-2_pkg_setup

	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc specs)
		$(use_with doc xmlto)
		--without-fop
	)
}
