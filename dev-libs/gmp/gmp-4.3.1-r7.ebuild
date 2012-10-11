# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmp/Attic/gmp-4.3.1.ebuild,v 1.10 2009/12/15 11:14:29 vapier Exp $

EAPI=4
inherit flag-o-matic eutils libtool rpm lts6-rpm

DESCRIPTION="Library for arithmetic on arbitrary precision integers, rational numbers, and floating-point numbers"
HOMEPAGE="http://gmplib.org/"
SRPM="gmp-4.3.1-7.el6_2.2.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
#	doc? ( http://www.nada.kth.se/~tege/${PN}-man-${PV}.pdf )"
RESTRICT="mirror"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="cxx static-libs" #doc

DEPEND="sys-devel/m4"
RDEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${PN}-4.1.4-noexecstack.patch
	epatch "${FILESDIR}"/${PN}-4.3.0-ABI-multilib.patch
	# Use the SRPM s390 patch.
	# epatch "${FILESDIR}"/${PN}-4.2.1-s390.diff
	epatch "${FILESDIR}"/${PN}-4.3.1-fix-broken-ansi-check.patch #296964

	sed -i -e 's:ABI = @ABI@:GMPABI = @GMPABI@:' \
		Makefile.in */Makefile.in */*/Makefile.in

	SRPM_PATCHLIST="Patch0: gmp-4.0.1-s390.patch
			Patch1: gmp-4.3.1-compat.patch
			Patch2: gmp-4.3.1-macro.patch"
	lts6_srpm_epatch || die

	# note: we cannot run autotools here as gcc depends on this package
	elibtoolize
}

src_configure() {
	# GMP believes hppa2.0 is 64bit
	local is_hppa_2_0
	if [[ ${CHOST} == hppa2.0-* ]] ; then
		is_hppa_2_0=1
		export CHOST=${CHOST/2.0/1.1}
	fi

	# ABI mappings (needs all architectures supported)
	case ${ABI} in
		32|x86)       export GMPABI=32;;
		64|amd64|n64) export GMPABI=64;;
		o32|n32)      export GMPABI=${ABI};;
	esac

	tc-export CC
	econf \
		--localstatedir=/var/state/gmp \
		--disable-mpfr \
		--disable-mpbsd \
		$(use_enable cxx) \
		$(use_enable static-libs static) \
		|| die "configure failed"

	# Fix the ABI for hppa2.0
	if [[ -n ${is_hppa_2_0} ]] ; then
		sed -i \
			-e 's:pa32/hppa1_1:pa32/hppa2_0:' \
			"${S}"/config.h || die
		export CHOST=${CHOST/1.1/2.0}
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	# should be a standalone lib
	rm -f "${D}"/usr/$(get_libdir)/libgmp.la
	# this requires libgmp
	local la="${D}/usr/$(get_libdir)/libgmpxx.la"
	use static-libs \
		&& sed -i 's:/[^ ]*/libgmp.la:-lgmp:' "${la}" \
		|| rm -f "${la}"

	dodoc AUTHORS ChangeLog NEWS README
	dodoc doc/configuration doc/isa_abi_headache
	dohtml -r doc

	#use doc && cp "${DISTDIR}"/gmp-man-${PV}.pdf "${D}"/usr/share/doc/${PF}/
}
