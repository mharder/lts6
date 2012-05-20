# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/flex/flex-2.5.35.ebuild,v 1.15 2011/09/06 18:59:44 mattst88 Exp $

EAPI="4"

inherit eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="The Fast Lexical Analyzer"
HOMEPAGE="http://flex.sourceforge.net/"
SRPM="flex-2.5.35-8.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="FLEX"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="nls static test"

RDEPEND="sys-devel/m4"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	test? ( sys-devel/bison )"

SRPM_PATCHLIST="
Patch0: flex-2.5.35-sign.patch
Patch1: flex-2.5.35-hardening.patch
Patch2: flex-2.5.35-gcc44.patch"

src_prepare() {
	[[ -n ${DEB_VER} ]] && epatch "${WORKDIR}"/${PN}_${PV}-${DEB_VER}.diff
	epatch "${FILESDIR}"/${PN}-2.5.34-isatty.patch #119598
	epatch "${FILESDIR}"/${PN}-2.5.33-pic.patch
	# Use EL SRPM version of patch.
	# epatch "${FILESDIR}"/${PN}-2.5.35-gcc44.patch
	sed -i 's:^LDFLAGS:LOADLIBES:' tests/test-pthread/Makefile.in #262989

	lts6_srpm_epatch || die
}

src_configure() {
	use static && append-ldflags -static
	econf $(use_enable nls) || die
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS ONEWS README* THANKS TODO || die
	dosym flex /usr/bin/lex
}
