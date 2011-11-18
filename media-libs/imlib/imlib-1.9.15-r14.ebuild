# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/imlib/imlib-1.9.15-r3.ebuild,v 1.7 2011/10/11 20:19:49 ssuominen Exp $

EAPI=3
inherit autotools eutils rpm lts6-rpm

PVP=(${PV//[-\._]/ })
DESCRIPTION="Image loading and rendering library"
HOMEPAGE="http://ftp.acc.umu.se/pub/GNOME/sources/imlib/1.9/"
SRPM="imlib-1.9.15-14.el6.src.rpm"
SRC_URI="mirror://lts6/sl6-added/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc static-libs"

RDEPEND=">=media-libs/tiff-3.5.5
	>=media-libs/giflib-4.1.0
	>=media-libs/libpng-1.2.1
	virtual/jpeg
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXext"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	# Automatic patch application is not working with this package
	# lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die
	epatch "${WORKDIR}/imlib-1.9.15-autotools-rebase.patch.bz2"
	epatch "${WORKDIR}/imlib-1.9.13-sec2.patch"
	epatch "${WORKDIR}/imlib-1.9.15-bpp16-CVE-2007-3568.patch"
	epatch "${WORKDIR}/imlib-1.9.10-cppflags.patch"
	epatch "${WORKDIR}/imlib-1.9.15-gmodulehack.patch"
	epatch "${WORKDIR}/imlib-1.9.13-underquoted.patch"
	epatch "${WORKDIR}/imlib-1.9.15-lib-bloat.patch"
	epatch "${WORKDIR}/imlib-1.9.15-multilib-config.patch"

	# Same as the imlib-1.9.15-fix-rendering.patch patch.
	# Use the Gentoo version since it has comments.
	# epatch "${WORKDIR}/imlib-1.9.15-check-for-shm-pixmaps.patch"

	# Fix aclocal underquoted definition warnings.
	# Conditionalize gdk functions for bug 40453.
	# Fix imlib-config for bug 3425.
	epatch "${FILESDIR}"/${P}.patch
	# Provided by SRPM patch imlib-1.9.13-sec2.patch
	# epatch "${FILESDIR}"/${PN}-security.patch #security #72681
	# Provided by SRPM patch imlib-1.9.15-bpp16-CVE-2007-3568.patch
	# epatch "${FILESDIR}"/${P}-bpp16-CVE-2007-3568.patch # security #201887
	epatch "${FILESDIR}"/${P}-fix-rendering.patch #197489

	# Superceeded by SRPM patch
	# epatch "${FILESDIR}"/${P}-asneeded.patch #207638
	epatch "${FILESDIR}"/${P}-libpng15.patch #357167

	mkdir m4 && cp "${FILESDIR}"/gtk-1-for-imlib.m4 m4

	AT_M4DIR="m4" eautoreconf
}

src_configure() {
	econf \
		--sysconfdir=/etc/imlib \
		$(use_enable static-libs static) \
		--disable-gdk \
		--disable-gtktest
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog README
	use doc && dohtml doc/*

	# Punt unused files
	rm -f "${D}"/usr/lib*/pkgconfig/imlibgdk.pc
	find "${D}" -name '*.la' -exec rm -f {} +
}
