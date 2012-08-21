# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libX11/libX11-1.4.4.ebuild,v 1.10 2012/04/26 18:57:55 aballier Exp $

EAPI=4

XORG_DOC=doc
# Enabling XORG_EAUTORECONF leads to dependency issues.
# XORG_EAUTORECONF=yes
inherit xorg-2 toolchain-funcs flag-o-matic rpm lts6-rpm

DESCRIPTION="X.Org X11 library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64  ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="ipv6 test +xcb"

SRPM="libX11-1.3-2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=">=x11-libs/xtrans-1.2.2
	x11-proto/kbproto
	>=x11-proto/xproto-7.0.15
	xcb? ( >=x11-libs/libxcb-1.2 )
	!xcb? (
		x11-libs/libXau
		x11-libs/libXdmcp
	)"
DEPEND="${RDEPEND}
	x11-proto/xf86bigfontproto
	x11-proto/bigreqsproto
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xcmiscproto
	x11-misc/util-macros
	test? ( dev-lang/perl )"

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		$(use_with doc xmlto)
		$(use_enable doc specs)
		$(use_enable ipv6)
		$(use_with xcb)
	)
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch2: dont-forward-keycode-0.patch
			Patch3: libX11-1.3.1-creategc-man-page.patch"
	lts6_srpm_epatch || die
}

src_configure() {
	[[ ${CHOST} == *-interix* ]] && export ac_cv_func_poll=no
	xorg-2_src_configure
}

src_compile() {
	# [Cross-Compile Love] Disable {C,LD}FLAGS and redefine CC= for 'makekeys'
	if tc-is-cross-compiler; then
		(
			filter-flags -m*
			emake -C "${AUTOTOOLS_BUILD_DIR}"/src/util CC=$(tc-getBUILD_CC) CFLAGS="${CFLAGS}" LDFLAGS="" clean all || die
		)
	fi
	xorg-2_src_compile
}
