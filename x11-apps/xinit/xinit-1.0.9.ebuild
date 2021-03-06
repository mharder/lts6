# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xinit/Attic/xinit-1.2.0-r4.ebuild,v 1.7 2010/11/13 19:22:05 armin76 Exp $

EAPI=4

inherit pam xorg-2 rpm lts6-rpm

DESCRIPTION="X Window System initializer"

LICENSE="${LICENSE} GPL-2"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd"
IUSE="+minimal pam"

SRPM="xorg-x11-xinit-1.0.9-13.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="
	x11-apps/xauth
	x11-libs/libX11
"
DEPEND="${RDEPEND}"
PDEPEND="x11-apps/xrdb
	!minimal? (
		x11-apps/xclock
		x11-apps/xsm
		x11-terms/xterm
		x11-wm/twm
	)
"

PATCHES=(
	"${FILESDIR}/0001-Gentoo-specific-customizations.patch"
)

SRPM_PATCHLIST="
Patch1: xinit-1.0.2-client-session.patch
# Patch2 is commented out in the SRPM spec file.
# Patch2: xinit-1.0.7-poke-ck.patch
Patch3: xinit-1.0.9-unset.patch
"

pkg_setup() {
	xorg-2_pkg_setup

	XORG_CONFIGURE_OPTIONS=(
		--with-xinitdir=/etc/X11/xinit
	)
}

src_prepare() {
	lts6_srpm_epatch || die

	xorg-2_src_prepare
}

src_install() {
	xorg-2_src_install

	exeinto /etc/X11
	doexe "${FILESDIR}"/chooser.sh "${FILESDIR}"/startDM.sh || die
	exeinto /etc/X11/Sessions
	doexe "${FILESDIR}"/Xsession || die
	exeinto /etc/X11/xinit
	doexe "${FILESDIR}"/xserverrc || die
	newinitd "${FILESDIR}"/xdm.initd-4 xdm || die
	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup || die
	newconfd "${FILESDIR}"/xdm.confd-2 xdm || die
	newpamd "${FILESDIR}"/xserver.pamd xserver
	dodir /etc/X11/xinit/xinitrc.d
	exeinto /etc/X11/xinit/xinitrc.d/
	doexe "${FILESDIR}/00-xhost"

	insinto /usr/share/xsessions
	doins "${FILESDIR}/Xsession.desktop"
}

pkg_postinst() {
	xorg-2_pkg_postinst
	ewarn "If you use startx to start X instead of a login manager like gdm/kdm,"
	ewarn "you can set the XSESSION variable to anything in /etc/X11/Sessions/ or"
	ewarn "any executable. When you run startx, it will run this as the login session."
	ewarn "You can set this in a file in /etc/env.d/ for the entire system,"
	ewarn "or set it per-user in ~/.bash_profile (or similar for other shells)."
	ewarn "Here's an example of setting it for the whole system:"
	ewarn "    echo XSESSION=\"Gnome\" > /etc/env.d/90xsession"
	ewarn "    env-update && source /etc/profile"
}
