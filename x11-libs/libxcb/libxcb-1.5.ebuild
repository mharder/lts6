# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libxcb/libxcb-1.8.1.ebuild,v 1.2 2012/03/10 01:13:39 chithanh Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X C-language Bindings library"
HOMEPAGE="http://xcb.freedesktop.org/"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="selinux"

SRPM="libxcb-1.5-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

# Upstream EL packages libxcb and xpyb.  However, the convention
# in portage is to separate the two packages into x11-libs/libxcb
# and x11-libs/xpyb.  So we need to restrict the srpm handling
# to only install libxcb in this ebuild.
SRPM_SUBPKG="${PN}-${PV}.tar.bz2"

RDEPEND="dev-libs/libpthread-stubs
	x11-libs/libXau
	x11-libs/libXdmcp"
DEPEND="${RDEPEND}
	dev-lang/python[xml]
	dev-libs/libxslt
	>=x11-proto/xcb-proto-1.6"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUBPKG}" || die "unpack failed!"
}

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable doc build-docs)
		$(use_enable selinux)
		--enable-xinput
	)
}
