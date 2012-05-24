# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/m4/Attic/m4-1.4.13.ebuild,v 1.3 2010/08/15 17:37:50 vapier dead $

EAPI="4"

inherit rpm lts6-rpm

DESCRIPTION="GNU macro processor"
HOMEPAGE="http://www.gnu.org/software/m4/m4.html"
SRPM="m4-1.4.13-5.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="examples"

# remember: cannot dep on autoconf since it needs us
DEPEND="app-arch/xz-utils"
RDEPEND=""

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.xz" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: m4-1.4.13-include.patch"
	lts6_srpm_epatch || die
}

src_configure() {
	# Disable automagic dependency over libsigsegv; see bug #278026
	export ac_cv_libsigsegv=no

	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && myconf="--program-prefix=g"
	econf \
		--enable-changeword \
		${myconf} \
		|| die
	emake || die
}

src_test() {
	[[ -d /none ]] && die "m4 tests will fail with /none/" #244396
	emake check || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc BACKLOG ChangeLog NEWS README* THANKS TODO
	if use examples ; then
		docinto examples
		dodoc examples/*
		rm -f "${D}"/usr/share/doc/${PF}/examples/Makefile*
	fi
	rm -f "${D}"/usr/lib/charset.alias #172864
}
