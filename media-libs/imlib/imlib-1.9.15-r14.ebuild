# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/imlib/imlib-1.9.15-r3.ebuild,v 1.7 2011/10/11 20:19:49 ssuominen Exp $

EAPI=4
inherit autotools eutils rpm lts6-rpm

PVP=(${PV//[-\._]/ })
DESCRIPTION="Image loading and rendering library"
HOMEPAGE="http://ftp.acc.umu.se/pub/GNOME/sources/imlib/1.9/"
SRPM="imlib-1.9.15-14.el6.src.rpm"
SRC_URI="mirror://lts62/sl6-added/${SRPM}"
SRPM_SUB_PKG="${PN}-${PV}.tar.bz2"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="doc static-libs"

RDEPEND=">=media-libs/tiff-3.5.5
	>=media-libs/giflib-4.1.0
	>=media-libs/libpng-1.2.1
	virtual/jpeg-lts6
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libXext"
DEPEND="${RDEPEND}"

SRPM_PATCHLIST="
Patch0:         imlib-1.9.15-autotools-rebase.patch.bz2
Patch1:         imlib-1.9.13-sec2.patch
Patch2:         imlib-1.9.15-bpp16-CVE-2007-3568.patch
Patch3:         imlib-1.9.10-cppflags.patch
Patch4:         imlib-1.9.15-gmodulehack.patch
Patch6:         imlib-1.9.13-underquoted.patch
Patch8:         imlib-1.9.15-lib-bloat.patch
Patch9:         imlib-1.9.15-multilib-config.patch
# Same as the imlib-1.9.15-fix-rendering.patch patch.
# Use the Gentoo version since it has comments.
# Patch10:        imlib-1.9.15-check-for-shm-pixmaps.patch
"

src_unpack() {
	# Explicitly unpack only imlib-1.9.15.tar.bz2
	# Leave the 'local-hack-gmodule.tar.gz' archive provided in the
	# SRPM alone.  Supposedly, it's purpose is to support building
	# with libpng rather than libpng10.
	# If there are future problems with png support, it will be
	# re-evaluated.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_SUB_PKG}" || die "unpack failed!"
}

src_prepare() {
	lts6_srpm_epatch || die

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
