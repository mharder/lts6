# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/Attic/poppler-0.12.4-r3.ebuild,v 1.14 2010/07/26 02:06:25 jer Exp $

EAPI="3"

CMAKE_MIN_VERSION="2.6.4"

inherit cmake-utils rpm lts6-rpm

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRPM="poppler-0.12.4-3.el6_0.1.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="+abiword cairo cjk debug doc exceptions jpeg jpeg2k +lcms png qt4 +utils +xpdf-headers"

COMMON_DEPEND="
	>=media-libs/fontconfig-2.6.0
	>=media-libs/freetype-2.3.9
	sys-libs/zlib
	abiword? ( dev-libs/libxml2:2 )
	cairo? (
		dev-libs/glib:2
		>=x11-libs/cairo-1.8.4
		>=x11-libs/gtk+-2.14.0:2
	)
	jpeg? ( virtual/jpeg )
	jpeg2k? ( media-libs/openjpeg )
	lcms? ( =media-libs/lcms-1* )
	png? ( media-libs/libpng )
	qt4? (
		x11-libs/qt-core:4
		x11-libs/qt-gui:4
	)
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	!dev-libs/poppler
	!dev-libs/poppler-glib
	!dev-libs/poppler-qt3
	!dev-libs/poppler-qt4
	!app-text/poppler-utils
	cjk? ( >=app-text/poppler-data-0.2.1 )
"

DOCS="AUTHORS ChangeLog NEWS README README-XPDF TODO"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die

	epatch "${FILESDIR}"/${PN}-0.12.3-cmake-disable-tests.patch
	epatch "${FILESDIR}"/${PN}-0.12.3-fix-headers-installation.patch
	epatch "${FILESDIR}"/${PN}-0.12.3-gdk.patch
	epatch "${FILESDIR}"/${PN}-0.12.3-darwin-gtk-link.patch
	epatch "${FILESDIR}"/${P}-config.patch  #304407
	# Included in SRPM patches
	# epatch "${FILESDIR}"/${PN}-0.12.3-cairo-downscale.patch  #303817
	epatch "${FILESDIR}"/${PN}-0.12.3-preserve-cflags.patch  #309297
	epatch "${FILESDIR}"/${PN}-0.12.4-nanosleep-rt.patch
	epatch "${FILESDIR}"/${PN}-0.12.4-strings_h.patch #314925
	epatch "${FILESDIR}"/${PN}-0.12.4-xopen_source.patch #314925
	# The whole _XOPEN_SOURCE thing breaks OSX Tiger and Solaris, this
	# is introduced by #309297, and made worse by #314925.  Since
	# vanilla sources don't have this enabled, the whole _XOPEN_SOURCE
	# isn't set by default, and hence correct from upstream's point of
	# view.  FreeBSD folks should file a proper bug for #314925 if they
	# really need it to compile vanilla sources.
	[[ ${CHOST} == *-darwin8 || ${CHOST} == *-solaris* ]] && \
		sed -i -e '/add_definitions/d' cmake/modules/PopplerMacros.cmake
}

src_configure() {
	mycmakeargs=(
		-DBUILD_GTK_TESTS=OFF
		-DBUILD_QT4_TESTS=OFF
		-DWITH_Qt3=OFF
		-DENABLE_SPLASH=ON
		-DENABLE_ZLIB=ON
		$(cmake-utils_use_enable abiword)
		$(cmake-utils_use_enable jpeg2k LIBOPENJPEG)
		$(cmake-utils_use_enable lcms)
		$(cmake-utils_use_enable utils)
		$(cmake-utils_use_enable xpdf-headers XPDF_HEADERS)
		$(cmake-utils_use_with cairo)
		$(cmake-utils_use_with cairo GTK)
		$(cmake-utils_use_with jpeg)
		$(cmake-utils_use_with png)
		$(cmake-utils_use_with qt4)
		$(cmake-utils_use exceptions USE_EXCEPTIONS)
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use cairo && use doc; then
		# For now install gtk-doc there
		insinto /usr/share/gtk-doc/html/poppler
		doins -r "${S}"/glib/reference/html/* || die 'failed to install API documentation'
	fi
}

pkg_postinst() {
	ewarn 'After upgrading app-text/poppler you may need to reinstall packages'
	ewarn 'depending on it. If you have gentoolkit installed, you can find those'
	ewarn 'with `equery d poppler`.'
}
