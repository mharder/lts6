# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/Attic/icu-4.2.1.ebuild,v 1.14 2010/10/02 22:30:46 arfrever dead $

EAPI="2"

inherit autotools eutils flag-o-matic versionator rpm lts6-rpm

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/ http://ibm.com/software/globalization/icu/"

SRPM="icu-4.2.1-9.1.el6_2.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="debug doc examples"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}/source"

SRPM_PATCHLIST="
Patch1:  icu-3.4-multiarchdevel.patch
Patch2:  icu.6995.kannada.patch
Patch3:  icu.icu7039.badextract.patch
# Same as Gentoo pkgdata patch 
# Patch4:  icu.6969.pkgdata.patch
Patch5:  icu.XXXX.install.patch
Patch6:  icu.7119.s390x.patch
Patch7:  canonicalize.patch
"

pkg_setup() {
	# ICU fails to build with enabled optimizations (bug #296901).
	if use arm || use ia64 || use sparc; then
		filter-flags -O*
	fi
}

src_prepare() {
	# Do not hardcode used CFLAGS, LDFLAGS etc. into icu-config
	# Bug 202059
	# http://bugs.icu-project.org/trac/ticket/6102
	for x in ARFLAGS CFLAGS CPPFLAGS CXXFLAGS FFLAGS LDFLAGS; do
		sed -i -e "/^${x} =.*/s:@${x}@::" "config/Makefile.inc.in" || die "sed failed"
	done

	epatch "${FILESDIR}/${P}-fix_misoptimizations-v2.patch"
	epatch "${FILESDIR}/${P}-pkgdata.patch"
	epatch "${FILESDIR}/${P}-pkgdata-build_data_without_assembly.patch"

	lts6_srpm_epatch || die

	eautoconf
}

src_configure() {
	econf \
		--enable-static \
		$(use_enable debug) \
		$(use_enable examples samples)
}

src_test() {
	emake -j1 check || die "emake check failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	dohtml ../readme.html
	dodoc ../unicode-license.txt
}
