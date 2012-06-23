# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/opensp/opensp-1.5.2-r3.ebuild,v 1.7 2012/06/20 20:06:19 maekke Exp $

EAPI="3"
inherit eutils flag-o-matic rpm lts6-rpm

MY_P=${P/opensp/OpenSP}
DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="http://openjade.sourceforge.net/"

SRPM="opensp-1.5.2-12.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="JamesClark"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="doc nls static-libs test"

DEPEND="nls? ( >=sys-devel/gettext-0.14.5 )
	doc? (
		app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2
	)
	test? (
		app-text/openjade
		app-text/sgml-common
	)"
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_prepare() {
	SRPM_PATCHLIST="Patch0: opensp-multilib.patch
			Patch1: opensp-nodeids.patch
			Patch2: opensp-sigsegv.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-1.5-gcc34.patch
	# The segfault patch is duplicated by the EL SRPM patch
	# opensp-sigsegv.patch
	# epatch "${FILESDIR}"/${P}-fix-segfault.patch
}

src_configure() {
	#
	# The following filters are taken from openjade's ebuild. See bug #100828.
	#

	# Please note!  Opts are disabled.  If you know what you're doing
	# feel free to remove this line.  It may cause problems with
	# docbook-sgml-utils among other things.
	ALLOWED_FLAGS="-O -O1 -O2 -pipe -g -march"
	strip-flags

	econf \
		--disable-dependency-tracking \
		--enable-http \
		--enable-default-catalog=/etc/sgml/catalog   \
		--enable-default-search-path=/usr/share/sgml \
		--datadir=/usr/share/sgml/${P}               \
		$(use_enable nls) \
		$(use_enable doc doc-build) \
		$(use_enable static-libs static)
}

src_compile() {
	emake pkgdocdir=/usr/share/doc/${PF} || die "Compilation failed"
}

src_test() {
	echo ">>> Test phase [check]: ${CATEGORY}/${PF}"
	einfo "Skipping tests known not to work"
	make SHOWSTOPPERS= check || die "Make test failed"
	SANDBOX_PREDICT="${SANDBOX_PREDICT%:/}"
}

src_install() {
	emake DESTDIR="${ED}" \
		pkgdocdir=/usr/share/doc/${PF} install || die "Installation failed"

	rm -f "${ED}"/usr/$(get_libdir)/*.la || die

	dodoc AUTHORS BUGS ChangeLog NEWS README
}

pkg_postinst() {
	ewarn "Please note that the soname of the library changed."
	ewarn "If you are upgrading from a previous version you need"
	ewarn "to fix dynamic linking inconsistencies by executing:"
	ewarn
	ewarn "    revdep-rebuild --library='libosp.so.*'"
}
