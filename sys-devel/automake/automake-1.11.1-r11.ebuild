# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.11.1-r1.ebuild,v 1.2 2012/01/19 20:55:45 slyfox Exp $

EAPI="4"

inherit eutils versionator rpm lts6-rpm

SRPM="automake-1.11.1-1.2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

# Use Gentoo versioning for slotting.
SLOT="${PV:0:4}"

DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://www.gnu.org/software/automake/"

LICENSE="GPL-2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

RDEPEND="dev-lang/perl
	>=sys-devel/automake-wrapper-3-r2
	>=sys-devel/autoconf-2.62
	>=sys-apps/texinfo-4.7
	sys-devel/gnuconfig"
DEPEND="${RDEPEND}
	sys-apps/help2man"

src_prepare() {
	SRPM_PATCHLIST="Patch0:     automake-1.11.1-novala.patch"
	lts6_srpm_epatch || die

	chmod a+rx tests/*.test
	sed -i \
		-e "s|: (automake)| v${SLOT}: (automake${SLOT})|" \
		doc/automake.texi || die "sed failed"
	mv doc/automake{,${SLOT}}.texi
	sed -i \
		-e "s:automake.info:automake${SLOT}.info:" \
		-e "s:automake.texi:automake${SLOT}.texi:" \
		doc/Makefile.in || die "sed on Makefile.in failed"
	epatch "${FILESDIR}"/${P}-check-java.patch #362323
	export WANT_AUTOCONF=2.5
}

src_configure() {
	econf --docdir=/usr/share/doc/${PF} HELP2MAN=true || die
}

src_compile() {
	emake APIVERSION="${SLOT}" pkgvdatadir="/usr/share/${PN}-${SLOT}" || die

	local x
	for x in aclocal automake; do
		help2man "perl -Ilib ${x}" > doc/${x}-${SLOT}.1
	done
}

src_install() {
	emake DESTDIR="${D}" install \
		APIVERSION="${SLOT}" pkgvdatadir="/usr/share/${PN}-${SLOT}" || die
	dodoc NEWS README THANKS TODO AUTHORS ChangeLog

	rm \
		"${D}"/usr/bin/{aclocal,automake} \
		"${D}"/usr/share/man/man1/{aclocal,automake}.1

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	local x
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}
