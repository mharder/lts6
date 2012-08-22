# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libpciaccess/libpciaccess-0.13.1.ebuild,v 1.8 2012/07/12 17:57:45 ranger Exp $

EAPI=4

inherit xorg-2 rpm lts6-rpm

DESCRIPTION="Library providing generic access to the PCI bus and devices"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="minimal zlib"

SRPM="libpciaccess-0.12.1-1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

DEPEND="!<x11-base/xorg-server-1.5
	zlib? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"

pkg_setup() {
	xorg-2_pkg_setup

	XORG_CONFIGURE_OPTIONS=(
		"$(use_with zlib)"
		"--with-pciids-path=${EPREFIX}/usr/share/misc"
	)
}

src_prepare() {
	SRPM_PATCHLIST="Patch2:         libpciaccess-rom-size.patch"
	lts6_srpm_epatch || die
}

src_install() {
	xorg-2_src_install
	if ! use minimal; then
		dodir /usr/bin || die
		${BASH} "${AUTOTOOLS_BUILD_DIR:-${S}}/libtool" --mode=install "$(type -P install)" -c "${AUTOTOOLS_BUILD_DIR:-${S}}/scanpci/scanpci" "${ED}"/usr/bin || die
	fi
}
