# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/apr/Attic/apr-1.3.9.ebuild,v 1.10 2011/05/14 20:57:07 arfrever dead $

EAPI="4"

inherit autotools eutils libtool multilib rpm lts6-rpm

DESCRIPTION="Apache Portable Runtime Library"
HOMEPAGE="http://apr.apache.org/"
SRPM="apr-1.3.9-3.el6_1.2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"

LICENSE="Apache-2.0"
SLOT="1"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="doc older-kernels-compatibility static-libs +urandom"
RESTRICT="mirror test"

DEPEND="doc? ( app-doc/doxygen )"
RDEPEND=""

DOCS=(CHANGES NOTICE README)

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	# Omit the following EL patches:
	# Patch3: apr-1.2.2-libdir.patch
	# Patch4: apr-1.2.7-pkgconf.patch
	#
	# They customize directory locations in a manner that
	# causes conflicts (specifically in building
	# apr-utils) in the Gentoo build environment.
	SRPM_PATCHLIST="Patch1: apr-0.9.7-deepbind.patch
			Patch2: apr-1.2.2-locktimeout.patch
			Patch10: apr-1.3.9-CVE-2011-0419.patch
			Patch11: apr-1.2.7-fnmatch.patch"
	lts6_srpm_epatch || die

	AT_M4DIR="build" eautoreconf
	elibtoolize

	epatch "${FILESDIR}/config.layout.patch"
}

src_configure() {
	local myconf

	if use older-kernels-compatibility; then
		local apr_cv_accept4 apr_cv_dup3 apr_cv_epoll_create1 apr_cv_sock_cloexec
		export apr_cv_accept4="no"
		export apr_cv_dup3="no"
		export apr_cv_epoll_create1="no"
		export apr_cv_sock_cloexec="no"
	fi

	if use urandom; then
		myconf+=" --with-devrandom=/dev/urandom"
	else
		myconf+=" --with-devrandom=/dev/random"
	fi

	CONFIG_SHELL="/bin/bash" econf \
		--enable-layout=gentoo \
		--enable-nonportable-atomics \
		--enable-threads \
		${myconf}

	# Make sure we use the system libtool.
	sed -i 's,$(apr_builddir)/libtool,/usr/bin/libtool,' build/apr_rules.mk
	sed -i 's,${installbuilddir}/libtool,/usr/bin/libtool,' apr-1-config
	rm -f libtool
}

src_compile() {
	emake -j1 || die "emake failed"

	if use doc; then
		emake -j1 dox || die "emake dox failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	find "${ED}" -name "*.la" -exec rm -f {} +

	if use doc; then
		dohtml -r docs/dox/html/* || die "dohtml failed"
	fi

	if ! use static-libs; then
		find "${ED}" -name "*.a" -exec rm -f {} +
	fi

	# This file is only used on AIX systems, which Gentoo is not,
	# and causes collisions between the SLOTs, so remove it.
	rm -f "${ED}usr/$(get_libdir)/apr.exp"
}
