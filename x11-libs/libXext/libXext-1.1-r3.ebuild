# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXext/libXext-1.3.1.ebuild,v 1.2 2012/04/26 19:06:49 aballier Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org Xext library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

SRPM="libXext-1.1-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=">=x11-libs/libX11-1.2
	>=x11-proto/xextproto-7.1"
DEPEND="${RDEPEND}
	>=x11-proto/xproto-7.0.16"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch1: libXext-1.1-XAllocID.patch"
	lts6_srpm_epatch || die
}

pkg_setup() {
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc specs)
		$(use_with doc xmlto)
		--without-fop
	)
}
