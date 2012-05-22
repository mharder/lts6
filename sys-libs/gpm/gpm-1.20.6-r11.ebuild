# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/gpm/gpm-1.20.6.ebuild,v 1.15 2011/08/11 02:25:13 vapier Exp $

# emacs support disabled due to #99533 #335900

EAPI="4"

inherit autotools eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Console-based mouse driver"
HOMEPAGE="http://www.nico.schottelius.org/software/gpm/"
SRPM="gpm-1.20.6-12.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc x86"
IUSE="selinux"

DEPEND="sys-libs/ncurses
	app-arch/xz-utils
	virtual/yacc"
RDEPEND="selinux? ( sec-policy/selinux-gpm )"

SRPM_PATCHLIST="
# Omit patch1, needs reworking, will revisit if necessary
# Patch1: gpm-1.20.6-multilib.patch
Patch2: gpm-1.20.1-lib-silent.patch
# Use the Gentoo 0001-daemon-use-sys-ioctl.h-for-ioctl patch instead
# Patch3: gpm-1.20.3-gcc4.3.patch
Patch4: gpm-1.20.5-close-fds.patch
Patch5: gpm-1.20.1-weak-wgetch.patch
Patch6: gpm-1.20.6-libtool.patch
"

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.lzma" || die
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.20.5-abi-v2.patch
	epatch "${FILESDIR}"/0001-daemon-use-sys-ioctl.h-for-ioctl.patch #222099
	epatch "${FILESDIR}"/0001-fixup-make-warnings.patch #206291

	lts6_srpm_epatch || die

	# workaround broken release
	find -name '*.o' -delete

	eautoreconf
}

src_configure() {
	econf \
		--sysconfdir=/etc/gpm \
		emacs=/bin/false
}

src_compile() {
	# make sure nothing compiled is left
	emake clean || die
	emake EMACS=: || die
}

src_install() {
	emake install DESTDIR="${D}" EMACS=: ELISP="" || die

	dosym libgpm.so.1 /usr/$(get_libdir)/libgpm.so
	gen_usr_ldscript -a gpm

	insinto /etc/gpm
	doins conf/gpm-*.conf

	dodoc BUGS Changes README TODO
	dodoc doc/Announce doc/FAQ doc/README*

	newinitd "${FILESDIR}"/gpm.rc6 gpm
	newconfd "${FILESDIR}"/gpm.conf.d gpm
}
