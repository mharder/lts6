# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/rgb/rgb-1.0.4.ebuild,v 1.9 2011/02/14 14:41:38 xarthisius Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="uncompile an rgb color-name database"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

SRPM="xorg-x11-server-utils-7.5-5.2.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "Subpackage unpack failed!"
}

# Note, "Patch1100: rgb-1.0.0-datadir-rgbpath-fix.patch" is commented
# out in the upstream SRPM spec file
#
# src_prepare() {
#	SRPM_PATCHLIST="Patch1100: rgb-1.0.0-datadir-rgbpath-fix.patch"
#	lts6_srpm_epatch || die
# }
