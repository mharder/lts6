# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xkeyboard-config/xkeyboard-config-2.3.ebuild,v 1.9 2011/10/03 18:07:33 josejx Exp $

EAPI=4

XORG_STATIC=no
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X keyboard configuration database"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/XKeyboardConfig"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

SRPM="xkeyboard-config-2.3-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"

RDEPEND="x11-apps/xkbcomp"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	x11-proto/xproto
	>=dev-util/intltool-0.30
	dev-perl/XML-Parser
	dev-util/intltool
	sys-devel/gettext"

XORG_CONFIGURE_OPTIONS=(
	--with-xkb-base="${EPREFIX}/usr/share/X11/xkb"
	--enable-compat-rules
	# do not check for runtime deps
	--disable-runtime-deps
	--with-xkb-rules-symlink=xorg
)

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	xorg-2_src_prepare

	SRPM_PATCHLIST="Patch1: 0001-Revert-Updated-lk-layout.patch"
	lts6_srpm_epatch || die

	if [[ ${XORG_EAUTORECONF} != no ]]; then
		intltoolize --copy --automake || die
	fi
}

src_compile() {
	# cleanup to make sure .dir files are regenerated
	# bug #328455 c#26
	xorg-2_src_compile clean
	xorg-2_src_compile
}
