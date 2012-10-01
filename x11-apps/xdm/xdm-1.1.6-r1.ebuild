# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xdm/Attic/xdm-1.1.6-r1.ebuild,v 1.9 2009/04/30 23:20:03 ssuominen dead $

EAPI="4"

# XORG_EAUTORECONF="yes"

inherit multilib xorg-2 pam systemd rpm lts6-rpm

DEFAULTVT="vt7"

DESCRIPTION="X.Org xdm application"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="ipv6 pam"

SRPM="xorg-x11-xdm-1.1.6-14.1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="x11-apps/xrdb
	x11-libs/libXdmcp
	x11-libs/libXaw
	>=x11-apps/xinit-1.0.2-r3
	x11-libs/libXinerama
	x11-libs/libXmu
	x11-libs/libX11
	x11-libs/libXt
	x11-apps/sessreg
	x11-apps/xconsole
	pam? ( virtual/pam )"
DEPEND="${RDEPEND}
	x11-proto/xineramaproto
	x11-proto/xproto"

RDEPEND="${RDEPEND}
	pam? ( sys-auth/pambase )"

SRPM_PATCHLIST="
# NOTE: Change xdm-config to invoke Xwilling with -s /bin/bash instead
# of -c to fix bug (#86505)
Patch10: xdm-1.0.1-redhat-xdm-config-fix.patch
# Defer to the Gentoo version of this patch
# Patch11: xdm-1.0.5-sessreg-utmp-fix-bug177890.patch

# NOTE: Change authorization to be saved in /var/lib/xdm (for
# cooperating with SELinux, see bug 388431 for more info)
Patch12: xdm-1.1.6-authDir-var-bug388431.patch

# Fix missing #endif in the Xresources (#470348)
Patch13: xdm-1.1.6-redhat-Xresources-fix.patch
"

pkg_setup() {
	# Omit the xwilling-hang.patch, the EL sources have a different
	# approach to fixing this in:
	# xdm-1.0.1-redhat-xdm-config-fix.patch
	PATCHES=(
		"${FILESDIR}/wtmp.patch"
		"${FILESDIR}/${P}-xdm_print.patch"
	)
	#	${FILESDIR}/xwilling-hang.patch

	XORG_CONFIGURE_OPTIONS=(
		$(use_enable ipv6)
		$(use_with pam)
		--with-default-vt=${DEFAULTVT}
		--with-xdmconfigdir=/etc/X11/xdm
	)
}

src_prepare() {
	lts6_srpm_epatch || die

	xorg-2_src_prepare

	eautoreconf
}

src_install() {
	xorg-2_src_install

	exeinto /usr/$(get_libdir)/X11/xdm
	doexe "${FILESDIR}"/Xsession

	use pam && pamd_mimic system-local-login xdm auth account session

	# Keep /var/lib/xdm. This is where authfiles are stored. See #286350.
	keepdir /var/lib/xdm
}

pkg_preinst() {
	xorg-2_pkg_preinst

	# Check for leftover /usr/lib/X11/xdm symlink
	if [[ -L "/usr/lib/X11/xdm" ]]; then
		ewarn "/usr/lib/X11/xdm is a symlink; deleting."
		rm /usr/lib/X11/xdm
	fi
}
