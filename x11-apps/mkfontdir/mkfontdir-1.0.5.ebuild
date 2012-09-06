# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/mkfontdir/mkfontdir-1.0.7.ebuild,v 1.9 2012/08/26 16:25:28 armin76 Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="create an index of X font files in a directory"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-font-utils-7.2-11.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND="x11-apps/mkfontscale"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "unpack failed!"
}
