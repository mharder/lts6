# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/help2man/Attic/help2man-1.36.4-r1.ebuild,v 1.10 2010/12/29 22:04:30 vapier dead $

EAPI="4"

inherit eutils rpm lts6-rpm

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="http://www.gnu.org/software/help2man"

SRPM="help2man-1.36.4-6.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls elibc_glibc"

RDEPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	elibc_glibc? ( nls? (
		dev-perl/Locale-gettext
		>=sys-devel/gettext-0.12.1-r1 ) )"


src_prepare() {
	SRPM_PATCHLIST="Patch0:         help2man-1.36.4.diff"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}/${P}-respect-LDFLAGS.patch"
}

src_configure() {
	local myconf
	use elibc_glibc && myconf="${myconf} $(use_enable nls)" \
		|| myconf="${myconf} --disable-nls"

	econf ${myconf} || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog NEWS README THANKS
}
