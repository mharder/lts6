# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.5.6.ebuild,v 1.1 2011/11/04 22:37:57 ssuominen Exp $

EAPI=4

inherit eutils libtool multilib rpm lts6-rpm

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRPM="libpng-1.2.48-1.el6_2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="static-libs"

RDEPEND="sys-libs/zlib
	!=media-libs/libpng-1.2*:1.2"
DEPEND="${RDEPEND}"

DOCS=( ANNOUNCE CHANGES example.c libpng-${PV}.txt README TODO )

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die

	elibtoolize
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +
}
