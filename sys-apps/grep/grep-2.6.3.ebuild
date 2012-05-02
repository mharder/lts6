# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.6.3.ebuild,v 1.1 2010/04/02 20:06:36 vapier Exp $

EAPI="4"

inherit rpm lts6-rpm

DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/"
SRPM="grep-2.6.3-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="nls pcre"

RDEPEND="nls? ( virtual/libintl )
	pcre? ( >=dev-libs/libpcre-7.8-r1 )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	rpm_src_unpack || die

	# The rpm eclass doesn't support .xz archives yet.
	unpack "./${P}.tar.xz" || die
}

src_prepare() {
	sed -i '1i#include "../lib/progname.h"' tests/get-mb-cur-max.c

	SRPM_PATCHLIST="Patch0: grep-2.6.3-dfa-optimize-period.patch
			Patch1: grep-2.6.3-glibc-matcher-fallback.patch
			Patch2: grep-2.6.3-mmap-option-fix.patch
			Patch3: grep-2.6.3-dfa-convert-to-wide-char.patch
			Patch4: grep-2.6.3-dfa-speedup-digit-xdigit.patch
			Patch5: grep-2.6.3-epipe-fix.patch"
	lts6_srpm_epatch || die
}

src_configure() {
	econf \
		--bindir=/bin \
		$(use_enable nls) \
		$(use_enable pcre perl-regexp) \
		$(use elibc_FreeBSD || echo --without-included-regex) \
		|| die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
