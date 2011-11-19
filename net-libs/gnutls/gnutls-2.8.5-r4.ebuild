# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/gnutls/Attic/gnutls-2.8.5.ebuild,v 1.8 2010/01/30 17:34:22 armin76 Exp $

EAPI="3"

inherit autotools libtool rpm lts6-rpm

DESCRIPTION="A TLS 1.0 and SSL 3.0 implementation for the GNU project"
HOMEPAGE="http://www.gnutls.org/"

SRPM="gnutls-2.8.5-4.el6.src.rpm"
SRC_URI="mirror://lts6/vendor/${SRPM}"
RESTRICT="mirror"

# GPL-3 for the gnutls-extras library and LGPL for the gnutls library.
LICENSE="LGPL-2.1 GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="bindist +cxx doc examples guile lzo nls zlib"

RDEPEND="dev-libs/libgpg-error
	>=dev-libs/libgcrypt-1.4.0
	>=dev-libs/libtasn1-0.3.4
	nls? ( virtual/libintl )
	guile? ( dev-scheme/guile[networking] )
	zlib? ( >=sys-libs/zlib-1.1 )
	!bindist? ( lzo? ( >=dev-libs/lzo-2 ) )"
DEPEND="${RDEPEND}
	sys-devel/libtool
	doc? ( dev-util/gtk-doc )
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if use lzo && use bindist; then
		ewarn "lzo support was disabled for binary distribution of gnutls"
		ewarn "due to licensing issues. See Bug 202381 for details."
		epause 5
	fi
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die

	epatch "${FILESDIR}/gnutls-2.8.5-safe-renogotiation-autoconf-fixes.patch"

	sed -e 's/imagesdir = $(infodir)/imagesdir = $(htmldir)/' -i doc/Makefile.am

	local dir
	for dir in m4 lib/m4 libextra/m4; do
		rm -f "${dir}/lt"* "${dir}/libtool.m4"
	done
	find . -name ltmain.sh -exec rm {} \;
	for dir in . lib libextra; do
		pushd "${dir}" > /dev/null
		eautoreconf
		popd > /dev/null
	done

	for i in auth_srp_rsa.c auth_srp_sb64.c auth_srp_passwd.c \
				auth_srp.c gnutls_srp.c ext_srp.c; do
		touch lib/$i
	done

	chmod a+x tests/safe-renegotiation/testsrn

	elibtoolize # for sane .so versioning on FreeBSD
}

src_configure() {
	local myconf
	use bindist && myconf="--without-lzo" || myconf="$(use_with lzo)"

	# The Upstream SRPM includes these configuration settings.
	myconf="${myconf} \
		--with-included-libcfg \
		--disable-static \
		--disable-openssl-compatibility \
		--disable-srp-authentication"

	econf --htmldir=/usr/share/doc/${P}/html \
		$(use_enable cxx) \
		$(use_enable doc gtk-doc) \
		$(use_enable guile) \
		$(use_enable nls) \
		$(use_with zlib) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README THANKS doc/TODO

	if use doc; then
		dodoc doc/gnutls.{pdf,ps}
		dohtml doc/gnutls.html
	fi

	if use examples; then
		docinto examples
		dodoc doc/examples/*.c
	fi

	find "${D}" -name "*.la" -delete || die "Failed removing .la files"
}
