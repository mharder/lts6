# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/luit/luit-1.1.1.ebuild,v 1.9 2012/08/26 16:23:40 armin76 Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="Locale and ISO 2022 support for Unicode terminals"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-apps-7.4-10.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="sys-libs/zlib
	x11-libs/libX11
	x11-libs/libfontenc"
DEPEND="${RDEPEND}"

XORG_CONFIGURE_OPTIONS=(
	--with-localealiasfile=${XDIR}/share/X11/locale/locale.alias
)

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "unpack failed!"
}
