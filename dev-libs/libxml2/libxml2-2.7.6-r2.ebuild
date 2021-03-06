# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libxml2/Attic/libxml2-2.7.6.ebuild,v 1.9 2010/08/09 04:09:07 zmedico Exp $

EAPI="3"

inherit libtool flag-o-matic eutils python rpm lts6-rpm

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="debug doc examples ipv6 python readline test"

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2004-01-14"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2004-01-14.tar.gz"

SRPM="libxml2-2.7.6-4.el6_2.4.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2} )"

RDEPEND="sys-libs/zlib
	python? ( || ( <dev-lang/python-3[xml] ( <dev-lang/python-3 dev-python/pyxml ) ) )
	readline? ( sys-libs/readline )"

DEPEND="${RDEPEND}
	hppa? ( >=sys-devel/binutils-2.15.92.0.2 )"

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi
}

src_unpack() {
	# ${A} isn't used to avoid unpacking of test tarballs into $WORKDIR,
	# as they are needed as tarballs in ${S}/xstc instead and not unpacked
	rpm_src_unpack ${SRPM}
	cd "${S}"

	if use test; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
	fi
}

src_prepare() {
	cd "${S}"
	SRPM_PATCHLIST="Patch0: libxml2-multilib.patch
			Patch1: libxml2-2.7.6-xpath-leak.patch
			Patch2: libxml2-2.7.7-xpath-bug.patch
			Patch3: libxml2-2.7.7-xpath-leak.patch
			Patch4: libxml2-2.7.7-xpath-axis-semantic.patch
			Patch5: libxml2-2.7.7-xpath-axis-semantic2.patch
			Patch6: libxml2-2.7.7-xpath-rounding.patch
			Patch7: libxml2-2.7.8-xpath-freeing.patch
			Patch8: libxml2-2.7.8-xpath-freeing2.patch
			Patch9: CVE-2011-1944.patch
			Patch10: libxml2-2.7.8-xpath-hardening.patch
			Patch11: CVE-2011-0216.patch
			Patch12: CVE-2011-2834.patch
			Patch13: CVE-2011-3905.patch
			Patch14: CVE-2011-3919.patch
			Patch15: CVE-2012-0841.patch
			Patch16: force_randomization.patch"
	lts6_srpm_epatch || die

	epunt_cxx
}

src_configure() {
	# USE zlib support breaks gnome2
	# (libgnomeprint for instance fails to compile with
	# fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).

	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.

	# --with-mem-debug causes unusual segmentation faults (bug #105120).

	local myconf="--with-zlib \
		--with-html-subdir=${PF}/html \
		--docdir=/usr/share/doc/${PF} \
		$(use_with debug run-debug)  \
		$(use_with python)           \
		$(use_with readline)         \
		$(use_with readline history) \
		$(use_enable ipv6) \
		PYTHON_SITE_PACKAGES=$(python_get_sitedir)"

	# Please do not remove, as else we get references to PORTAGE_TMPDIR
	# in /usr/lib/python?.?/site-packages/libxml2mod.la among things.
	elibtoolize

	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	econf $myconf
}

src_install() {
	emake DESTDIR="${D}" \
		EXAMPLES_DIR=/usr/share/doc/${PF}/examples \
		docsdir=/usr/share/doc/${PF}/python \
		exampledir=/usr/share/doc/${PF}/python/examples \
		install || die "Installation failed"

	rm -rf "${D}"/usr/share/doc/${P}
	dodoc AUTHORS ChangeLog Copyright NEWS README* TODO* || die "dodoc failed"

	if ! use python; then
		rm -rf "${D}"/usr/share/doc/${PF}/python
		rm -rf "${D}"/usr/share/doc/${PN}-python-${PV}
	fi

	if ! use doc; then
		rm -rf "${D}"/usr/share/gtk-doc
		rm -rf "${D}"/usr/share/doc/${PF}/html
	fi

	if ! use examples; then
		rm -rf "${D}/usr/share/doc/${PF}/examples"
		rm -rf "${D}/usr/share/doc/${PF}/python/examples"
	fi
}

pkg_postinst() {
	if use python; then
		python_mod_optimize drv_libxml2.py libxml2.py
	fi

	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [ "${ROOT}" != "/" ]
	then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${ROOT}etc/xml/catalog"

		# we dont want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [ ! -e ${CATALOG} ]; then
			[ -d "${ROOT}etc/xml" ] || mkdir -p "${ROOT}etc/xml"
			/usr/bin/xmlcatalog --create > ${CATALOG}
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup drv_libxml2.py libxml2.py
	fi
}
