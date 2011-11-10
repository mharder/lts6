# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/which/which-2.19.ebuild,v 1.9 2008/03/29 15:28:11 ranger Exp $

inherit eutils rpm lts6-rpm

DESCRIPTION="Prints out location of specified executables that are in your path"
HOMEPAGE="http://www.xs4all.nl/~carlo17/which/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

DEPEND="sys-apps/texinfo"
RDEPEND=""

MY_PV="2.19"
SRPM="${PN}-${MY_PV}-6.el6.src.rpm"
SRC_URI="http://ftp.scientificlinux.org/linux/scientific/6.1/SRPMS/vendor/${SRPM}"
S="${WORKDIR}/${PN}-${MY_PV}"

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}"/which.spec || die
	epatch "${FILESDIR}"/which-gentoo.patch
	epatch "${FILESDIR}"/which-2.19-remove-readline.patch
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS EXAMPLES NEWS README*
}
