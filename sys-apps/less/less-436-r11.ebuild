# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/less/less-436.ebuild,v 1.11 2010/02/14 17:10:59 vapier Exp $

EAPI="4"

inherit eutils rpm lts6-rpm

DESCRIPTION="Excellent text file viewer"
HOMEPAGE="http://www.greenwoodsoftware.com/less/"
SRPM="less-436-10.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	http://www-zeuthen.desy.de/~friebel/unix/less/code2color"

LICENSE="|| ( GPL-3 BSD-2 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="unicode"

DEPEND=">=sys-libs/ncurses-5.2"

SRPM_PATCHLIST="
Patch1: less-406-Foption.patch
Patch4: less-394-time.patch
Patch5: less-418-fsync.patch
Patch6: less-436-manpage.patch
Patch7: less-436-add-old-bot-option-in-man-page.patch
Patch8: less-436-help.patch
"

src_prepare() {
	cp "${DISTDIR}"/code2color "${S}"/
	epatch "${FILESDIR}"/code2color.patch

	lts6_srpm_epatch || die
}

yesno() { use $1 && echo yes || echo no ; }

src_configure() {
	export ac_cv_lib_ncursesw_initscr=$(yesno unicode)
	export ac_cv_lib_ncurses_initscr=$(yesno !unicode)
	econf || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	dobin code2color || die "dobin"
	newbin "${FILESDIR}"/lesspipe.sh lesspipe || die "newbin"
	dosym lesspipe /usr/bin/lesspipe.sh
	newenvd "${FILESDIR}"/less.envd 70less

	dodoc NEWS README* "${FILESDIR}"/README.Gentoo
}

pkg_postinst() {
	einfo "lesspipe offers colorization options.  Run 'lesspipe -h' for info."
}
