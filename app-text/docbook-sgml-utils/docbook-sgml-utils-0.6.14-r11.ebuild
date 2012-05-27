# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/docbook-sgml-utils/docbook-sgml-utils-0.6.14-r1.ebuild,v 1.11 2012/05/09 14:33:39 aballier Exp $

EAPI=4

inherit eutils autotools prefix rpm lts6-rpm

MY_PN=${PN/-sgml/}
MY_P=${MY_PN}-${PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Shell scripts to manage DocBook documents"
HOMEPAGE="http://sources.redhat.com/docbook-tools/"
SRPM="docbook-utils-0.6.14-24.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="jadetex"

DEPEND=">=dev-lang/perl-5
	app-text/docbook-dsssl-stylesheets
	app-text/openjade
	dev-perl/SGMLSpm
	~app-text/docbook-xml-simple-dtd-4.1.2.4
	~app-text/docbook-xml-simple-dtd-1.0
	app-text/docbook-xml-dtd
	~app-text/docbook-sgml-dtd-3.0
	~app-text/docbook-sgml-dtd-3.1
	~app-text/docbook-sgml-dtd-4.0
	~app-text/docbook-sgml-dtd-4.1
	jadetex? ( app-text/jadetex )
	userland_GNU? ( sys-apps/which )"

	# Remove the lynx/links/elinks dependency
	# for the purposes of meeting installation requirements,
	# the less command can view these documents.  It's up to
	# the user to select the optimal viewer for the docs.
	#
	# || (
	#	www-client/lynx
	#	www-client/links
	#	www-client/elinks
	#	virtual/w3m )"
RDEPEND="${DEPEND}"

# including both xml-simple-dtd 4.1.2.4 and 1.0, to ease
# transition to simple-dtd 1.0, <obz@gentoo.org>

SRPM_PATCHLIST="
Patch0: docbook-utils-spaces.patch
Patch1: docbook-utils-2ndspaces.patch
Patch2: docbook-utils-w3mtxtconvert.patch
# Defer to the Gentoo grep patch 
# Patch3: docbook-utils-grepnocolors.patch
Patch4: docbook-utils-sgmlinclude.patch
Patch5: docbook-utils-rtfmanpage.patch
Patch6: docbook-utils-papersize.patch
Patch7: docbook-utils-nofinalecho.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${MY_P}-elinks.patch
	epatch "${FILESDIR}"/${P}-grep-2.7.patch
	if use prefix; then
		epatch "${FILESDIR}"/${MY_P}-prefix.patch
		eprefixify doc/{man,HTML}/Makefile.am bin/jw.in backends/txt configure.in
		eautoreconf
	fi
}

src_install() {
	make DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		install || die "Installation failed"

	if ! use jadetex ; then
		for i in dvi pdf ps ; do
			rm "${ED}"/usr/bin/docbook2$i || die
			rm "${ED}"/usr/share/sgml/docbook/utils-${PV}/backends/$i || die
			rm "${ED}"/usr/share/man/man1/docbook2$i.1 || die
		done
	fi
	dodoc AUTHORS ChangeLog NEWS README TODO || die
}
