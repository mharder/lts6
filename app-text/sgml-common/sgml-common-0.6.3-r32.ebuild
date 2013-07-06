# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/sgml-common/sgml-common-0.6.3-r5.ebuild,v 1.27 2013/02/17 20:39:27 zmedico Exp $

EAPI="4"

WANT_AUTOMAKE="1.4"
AUTOTOOLS_AUTO_DEPEND="yes"

inherit autotools eutils prefix rpm lts6-rpm

DESCRIPTION="Base ISO character entities and utilities for SGML"
HOMEPAGE="http://www.iso.ch/cate/3524030.html"

SRPM="sgml-common-0.6.3-32.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

SRPM_PATCHLIST="
Patch0: sgml-common-umask.patch
# Patch1: sgml-common-xmldir.patch
# Use the Gentoo version of install-catalog.in
# Patch2: sgml-common-quotes.patch
"

src_prepare() {
	# We use a hacked version of install-catalog that supports the ROOT
	# variable, puts quotes around the CATALOG files, and can be prefixed.
	cp "${FILESDIR}/${P}-install-catalog.in" "${S}/bin/install-catalog.in"

	# replace bogus links with files
	for file in COPYING INSTALL install-sh missing mkinstalldirs; do
		rm $file
		cp -p /usr/share/automake-1.4/$file .
	done

	lts6_srpm_epatch

	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify bin/install-catalog.in bin/sgmlwhich config/sgml.conf
}

# src_configure() {
#	econf --htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
# }

src_install() {
	emake DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		install || die "emake install failed"
}

pkg_postinst() {
	local installer="${EROOT}usr/bin/install-catalog"
	if [[ ! -x ${installer} ]]; then
		eerror "install-catalog not found! Something went wrong!"
		die "install-catalog not found! Something went wrong!"
	fi

	einfo "Installing Catalogs..."
	"$installer" --add \
		"${EPREFIX}"/etc/sgml/sgml-ent.cat \
		"${EPREFIX}"/usr/share/sgml/sgml-iso-entities-8879.1986/catalog
	"$installer" --add \
		"${EPREFIX}"/etc/sgml/sgml-docbook.cat \
		"${EPREFIX}"/etc/sgml/sgml-ent.cat

	local file
	for file in `find "${EROOT}etc/sgml/" -name "*.cat"` "${EROOT}etc/sgml/catalog"
	do
		einfo "Fixing ${file}"
		awk '/"$/ { print $1 " " $2 }
			! /"$/ { print $1 " \"" $2 "\"" }' ${file} > ${file}.new
		mv ${file}.new ${file}
	done
}

pkg_prerm() {
	cp "${EROOT}usr/bin/install-catalog" "${T}"
}

pkg_postrm() {
	if [ ! -x  "${T}/install-catalog" ]; then
		return
	fi

	einfo "Removing Catalogs..."
	if [ -e "${EROOT}etc/sgml/sgml-ent.cat" ]; then
		"${T}"/install-catalog --remove \
			"${EPREFIX}"/etc/sgml/sgml-ent.cat \
			"${EPREFIX}"/usr/share/sgml/sgml-iso-entities-8879.1986/catalog
	fi

	if [ -e "${EROOT}etc/sgml/sgml-docbook.cat" ]; then
		"${T}"/install-catalog --remove \
			"${EPREFIX}"/etc/sgml/sgml-docbook.cat \
			"${EPREFIX}"/etc/sgml/sgml-ent.cat
	fi
}
