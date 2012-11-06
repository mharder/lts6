# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xbitmaps/xbitmaps-1.1.1.ebuild,v 1.10 2012/05/06 00:06:33 aballier Exp $

EAPI="4"

XORG_MODULE=data/
XORG_STATIC=no
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org bitmaps data"
SRPM="xorg-x11-xbitmaps-1.0.1-9.1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_src_unpack || die
}
