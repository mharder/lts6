# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/mpfr/Attic/mpfr-2.4.1_p5.ebuild,v 1.11 2011/04/05 00:51:45 vapier dead $

EAPI="4"

# NOTE: we cannot depend on autotools here starting with gcc-4.3.x
inherit eutils rpm lts6-rpm

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="http://www.mpfr.org/"

SRPM="mpfr-2.4.1-6.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="static-libs"

RDEPEND=">=dev-libs/gmp-4.1.4-r2"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

S=${WORKDIR}/${MY_P}

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${MY_P}.tar.lzma" || die
}

src_prepare() {
	epatch "${FILESDIR}"/${MY_PV}/patch*

	SRPM_PATCHLIST="Patch0: mpfr-2.4.1-sa.patch"
	lts6_srpm_epatch || die

	sed -i '/if test/s:==:=:' configure #261016
	find . -type f -print0 | xargs -0 touch -r configure
}

src_configure() {
	econf \
		--docdir=/usr/share/doc/${PF} \
		$(use_enable static-libs static)
}

src_install() {
	emake install DESTDIR="${D}" || die
	use static-libs || rm "${D}"/usr/*/libmpfr.{la,so} || die

	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
	dohtml *.html
}
