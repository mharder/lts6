# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/Attic/libpcre-7.8-r2.ebuild,v 1.3 2009/10/21 08:56:24 loki_val dead $

EAPI="4"

inherit libtool eutils toolchain-funcs autotools rpm lts6-rpm

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"

SRPM="pcre-7.8-4.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="3"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="bzip2 +cxx doc unicode zlib static-libs"

DEPEND="virtual/pkgconfig"
RDEPEND=""

S="${WORKDIR}/pcre-${PV}"

src_prepare() {
	sed -i -e "s:libdir=@libdir@:libdir=/$(get_libdir):" libpcre.pc.in || die "Fixing libpcre pkgconfig files failed"
	sed -i -e "s:-lpcre ::" libpcrecpp.pc.in || die "Fixing libpcrecpp pkgconfig files failed"
	echo "Requires: libpcre = @PACKAGE_VERSION@" >> libpcrecpp.pc.in
	epatch "${FILESDIR}"/libpcre-7.9-pkg-config.patch

	SRPM_PATCHLIST="Patch0: pcre-7.3-multilib.patch
			# In upstream, bugs #676636, #676643
			Patch1: pcre-8.12-manual_typos.patch
			# Refused by upstream, bug #676636
			Patch2: pcre-8.12-refused_spelling_terminated.patch"
	lts6_srpm_epatch || die

	eautoreconf
	elibtoolize
}

src_configure() {
	econf --with-match-limit-recursion=8192 \
		$(use_enable unicode utf8) $(use_enable unicode unicode-properties) \
		$(use_enable cxx cpp) \
		$(use_enable zlib pcregrep-libz) \
		$(use_enable bzip2 pcregrep-libbz2) \
		$(use_enable static-libs static) \
		--enable-shared \
		--htmldir=/usr/share/doc/${PF}/html \
		--docdir=/usr/share/doc/${PF} \
		|| die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	gen_usr_ldscript -a pcre

	dodoc doc/*.txt AUTHORS
	use doc && dohtml doc/html/*
	find "${D}" -type f -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}

pkg_preinst() {
	preserve_old_lib /$(get_libdir)/libpcre.so.0
}

pkg_postinst() {
	preserve_old_lib_notify /$(get_libdir)/libpcre.so.0
}
