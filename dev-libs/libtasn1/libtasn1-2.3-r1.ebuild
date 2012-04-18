# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#  $Header: $

EAPI=4

inherit rpm lts6-rpm

DESCRIPTION="ASN.1 library"
HOMEPAGE="http://www.gnu.org/software/libtasn1/"
SRPM="libtasn1-2.3-3.el6_2.1.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="doc static-libs"

DEPEND=">=dev-lang/perl-5.6
	sys-devel/bison"
RDEPEND=""

DOCS=( AUTHORS ChangeLog NEWS README THANKS )

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	SRPM_PATCHLIST="Patch1:         libtasn1-2.4-rpath.patch
			Patch2:         libtasn1-2.3-cve-2012-1569.patch"
	lts6_srpm_epatch || die
}

src_configure(){
	local myconf

	[[ "${VALGRIND_TESTS}" == "0" ]] && myconf+=" --disable-valgrind-tests"
	econf \
		$(use_enable static-libs static) \
		${myconf}
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +

	if use doc; then
		dodoc doc/libtasn1.ps || die "dodoc failed"
	fi
}
