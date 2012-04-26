# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXi/Attic/libXi-1.3.ebuild,v 1.9 2010/08/02 18:24:09 armin76 Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org Xi library"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

SRPM="libXi-1.3-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=">=x11-libs/libX11-1.3
	>=x11-libs/libXext-1.1
	>=x11-proto/inputproto-2.0
"
DEPEND="${RDEPEND}
	>=x11-proto/xproto-7.0.16
"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch1: libXi-1.3-right-event-number.patch"
	lts6_srpm_epatch || die
}

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc specs)
		$(use_with doc xmlto)
		$(use_with doc asciidoc)
		--without-fop
	)
}

pkg_postinst() {
	xorg-2_pkg_postinst

	ewarn "Some special keys and keyboard layouts may stop working."
	ewarn "To fix them, recompile xorg-server."
}
