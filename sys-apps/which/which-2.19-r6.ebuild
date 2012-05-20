# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/which/which-2.19.ebuild,v 1.9 2008/03/29 15:28:11 ranger Exp $

EAPI=4

inherit eutils rpm lts6-rpm

DESCRIPTION="Prints out location of specified executables that are in your path"
HOMEPAGE="http://www.xs4all.nl/~carlo17/which/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

DEPEND="sys-apps/texinfo"
RDEPEND=""

SRPM="which-2.19-6.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

SRPM_PATCHLIST="Patch: which-2.19-afs.patch"

src_prepare() {
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/which-gentoo.patch
	epatch "${FILESDIR}"/which-2.19-remove-readline.patch
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS EXAMPLES NEWS README*
}
