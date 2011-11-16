# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.3-r1.ebuild,v 1.15 2011/02/06 21:36:45 leio Exp $

EAPI="3"
inherit autotools eutils flag-o-matic toolchain-funcs rpm lts6-rpm

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRPM="zlib-1.2.3-26.el6.src.rpm"
SRC_URI="mirror://lts6/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="static-libs"

RDEPEND=""

src_unpack() {
	rpm_src_unpack || die
}

src_prepare () {
	cd "${S}"

	# lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die
	#
	# Automatically applying all SRPM patches will not work
	# for this ebuild

	# To-Do: The following patch is used in EL to prepare
	# the source for autotools.  I haven't sorted through
	# the details of making this work, but it seems interesting.
	# epatch "${WORKDIR}/zlib-1.2.3-autotools.patch"

	epatch "${WORKDIR}/minizip-1.2.3-malloc.patch"
	# The zlib-1.2.3-pc_file.patch relies on the autotools patch
	# epatch "${WORKDIR}/zlib-1.2.3-pc_file.patch"
	epatch "${WORKDIR}/zlib-1.2.3-622779.patch"

	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-visibility-support.patch #149929
	epatch "${FILESDIR}"/${PN}-1.2.1-glibc.patch
	epatch "${FILESDIR}"/${PN}-1.2.1-build-fPIC.patch
	epatch "${FILESDIR}"/${PN}-1.2.1-configure.patch #55434
	epatch "${FILESDIR}"/${PN}-1.2.1-fPIC.patch
	epatch "${FILESDIR}"/${PN}-1.2.3-r1-bsd-soname.patch #123571
	epatch "${FILESDIR}"/${PN}-1.2.3-LDFLAGS.patch #126718
	epatch "${FILESDIR}"/${PN}-1.2.3-mingw-implib.patch #288212
	sed -i -e '/ldconfig/d' Makefile*

	cp "${WORKDIR}/zlib.pc.in" "${S}"
}

echoit() { echo "$@"; "$@"; }

src_configure() {
	tc-export AR CC RANLIB
	case ${CHOST} in
	*-mingw*|mingw*)
		;;
	*)
		# not an autoconf script, so cant use econf
		echoit ./configure --shared --prefix=/usr --libdir=/$(get_libdir) || die
		;;
	esac
}

src_compile() {
	tc-export AR CC RANLIB
	case ${CHOST} in
	*-mingw*|mingw*)
		export RC=${CHOST}-windres DLLWRAP=${CHOST}-dllwrap
		emake -f win32/Makefile.gcc prefix=/usr || die
		;;
	*)
		emake || die
		;;
	esac

	sed \
		-e 's|@prefix@|/usr|g' \
		-e 's|@exec_prefix@|${prefix}|g' \
		-e 's|@libdir@|${exec_prefix}/'$(get_libdir)'|g' \
		-e 's|@sharedlibdir@|${exec_prefix}/'$(get_libdir)'|g' \
		-e 's|@includedir@|${prefix}/include|g' \
		-e 's|@VERSION@|'${PV}'|g' \
		zlib.pc.in > zlib.pc || die
}

sed_macros() {
	# clean up namespace a little #383179
	# we do it here so we only have to tweak 2 files
	sed -i -r 's:\<(O[FN])\>:_Z_\1:g' "$@" || die
}

src_install() {
	einstall libdir="${D}"/$(get_libdir) || die
	rm "${D}"/$(get_libdir)/libz.a
	insinto /usr/include
	doins zconf.h zlib.h

	doman zlib.3
	dodoc FAQ README ChangeLog algorithm.txt

	# we don't need the static lib in /lib
	# as it's only for compiling against
	dolib libz.a

	# all the shared libs go into /lib
	# for NFS based /usr
	case ${CHOST} in
	*-mingw*|mingw*)
		dobin zlib1.dll || die
		dolib libz.dll.a || die
		;;
	*)
		into /
		dolib libz.so.${PV}
		( cd "${D}"/$(get_libdir) ; chmod 755 libz.so.* )
		dosym libz.so.${PV} /$(get_libdir)/libz.so
		dosym libz.so.${PV} /$(get_libdir)/libz.so.1
		gen_usr_ldscript libz.so
		sed_macros "${D}"/usr/include/*.h
		;;
	esac

	insinto /usr/lib/pkgconfig
	doins zlib.pc || die

	use static-libs || rm -f "${D}"/usr/$(get_libdir)/*.{a,la}
}
