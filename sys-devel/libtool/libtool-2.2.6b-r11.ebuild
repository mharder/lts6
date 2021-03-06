# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/libtool/Attic/libtool-2.2.6b.ebuild,v 1.8 2010/07/06 12:41:38 vapier Exp $

EAPI="2" #356089

LIBTOOLIZE="true" #225559
WANT_LIBTOOL="none"
inherit eutils autotools flag-o-matic multilib rpm lts6-rpm

DESCRIPTION="A shared library tool for developers"
HOMEPAGE="http://www.gnu.org/software/libtool/"

SRPM="libtool-2.2.6-15.5.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="test vanilla"

RDEPEND="sys-devel/gnuconfig
	!<sys-devel/autoconf-2.62:2.5
	!<sys-devel/automake-1.11.1:1.11"
DEPEND="${RDEPEND}
	app-arch/xz-utils
	sys-apps/help2man"

pkg_setup() {
	if use test && ! has_version '>sys-devel/binutils-2.19.51'; then
		einfo "Disabling --as-needed, since you got older binutils and you asked"
		einfo "to run tests. With the stricter (older) --as-needed behaviour"
		einfo "you'd be seeing a test failure in test #63; this has been fixed"
		einfo "in the newer version of binutils."
		append-ldflags $(no-as-needed)
	fi
}

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.lzma" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0:  libtool-2.2.6a-rpath.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-2.2.6a-tests-locale.patch #249168

	if ! use vanilla ; then
		epunt_cxx
		cd libltdl/m4
		epatch "${FILESDIR}"/${PN}-1.5.20-use-linux-version-in-fbsd.patch #109105
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
		cd ..
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi
}

src_configure() {
	# the libtool script uses bash code in it and at configure time, tries
	# to find a bash shell.  if /bin/sh is bash, it uses that.  this can
	# cause problems for people who switch /bin/sh on the fly to other
	# shells, so just force libtool to use /bin/bash all the time.
	export CONFIG_SHELL=/bin/bash

	default
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* NEWS README THANKS TODO doc/PLATFORMS

	local x
	for x in libtool libtoolize ; do
		help2man ${x} > ${x}.1
		doman ${x}.1 || die
	done

	for x in $(find "${D}" -name config.guess -o -name config.sub) ; do
		rm -f "${x}" ; ln -sf /usr/share/gnuconfig/${x##*/} "${x}"
	done
}

pkg_preinst() {
	preserve_old_lib /usr/$(get_libdir)/libltdl.so.3
}

pkg_postinst() {
	preserve_old_lib_notify /usr/$(get_libdir)/libltdl.so.3
}
