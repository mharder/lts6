# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/xtrans/xtrans-1.2.7.ebuild,v 1.8 2012/07/12 18:03:04 ranger Exp $

EAPI=4

XORG_PACKAGE_NAME="lib${PN}"
# this package just installs some .c and .h files, no libraries
XORG_STATIC=no
XORG_DOC=doc
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org xtrans library"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="xorg-x11-xtrans-devel-1.2.2-4.1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

src_prepare() {
	SRPM_PATCHLIST="Patch1: xtrans-1.0.3-avoid-gethostname.patch"
	lts6_srpm_epatch || die
}
