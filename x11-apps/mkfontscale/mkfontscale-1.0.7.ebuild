# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontscale/Attic/mkfontscale-1.0.7.ebuild,v 1.11 2010/07/02 16:50:11 darkside Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="create an index of scalable font files for X"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-font-utils-7.2-11.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="x11-libs/libfontenc
	media-libs/freetype:2"
DEPEND="${RDEPEND}
	x11-proto/xproto
	app-arch/gzip
	app-arch/bzip2"

XORG_CONFIGURE_OPTIONS=(
	--with-bzip2
)

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "unpack failed!"
}
