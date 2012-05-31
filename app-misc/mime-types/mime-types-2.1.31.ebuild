# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mime-types/mime-types-8.ebuild,v 1.9 2012/04/26 12:16:46 aballier Exp $

inherit rpm lts6-rpm

DESCRIPTION="Provides /etc/mime.types file"
HOMEPAGE="http://www.gentoo.org/"

SRPM="mailcap-2.1.31-2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"
S="${WORKDIR}/mailcap-${PV}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"
	SRPM_PATCHLIST="Patch1:         mailcap-webm.patch"
	lts6_srpm_epatch || die
}

src_install() {
	insinto /etc
	doins mime.types || die
}
