# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/psmisc/Attic/psmisc-22.6.ebuild,v 1.8 2009/05/14 18:16:53 josejx Exp $

EAPI="4"
inherit autotools eutils rpm lts6-rpm

DESCRIPTION="A set of tools that use the proc filesystem"
HOMEPAGE="http://psmisc.sourceforge.net/"
SRPM="psmisc-22.6-15.el6_0.1.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="ipv6 nls selinux X"

RDEPEND=">=sys-libs/ncurses-5.2-r2
	selinux? ( sys-libs/libselinux )"
DEPEND="${RDEPEND}
	sys-devel/libtool
	nls? ( sys-devel/gettext )"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: psmisc-22.6-types.patch
			Patch1: psmisc-22.6-pstree-overflow.patch
			Patch2: psmisc-22.6-fuser-remove-mountlist.patch
			Patch3: psmisc-22.6-overflow2.patch
			Patch4: psmisc-22.6-udp.patch
			Patch5: psmisc-22.6-peekfd-segv.patch
			Patch6: psmisc-22.6-killall-pgid.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-22.5-sockets.patch
	# this package doesnt actually need C++
	sed -i '/AC_PROG_CXX/d' configure.ac || die
	use nls || epatch "${FILESDIR}"/${PN}-22.5-no-nls.patch #193920
	eautoreconf
}

src_configure() {
	# the nls looks weird, but it's because we actually delete the nls stuff
	# above when USE=-nls.  this should get cleaned up so we dont have to patch
	# it out, but until then, let's not confuse users ... #220787
	econf \
		$(use_enable selinux) \
		$(use nls && use_enable nls) \
		$(use_enable ipv6) \
		|| die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README
	use X || rm "${ED}"/usr/bin/pstree.x11
	# fuser is needed by init.d scripts
	dodir /bin
	mv "${ED}"/usr/bin/fuser "${ED}"/bin/ || die
	# easier to do this than forcing regen of autotools
	[[ -e ${ED}/usr/bin/peekfd ]] || rm -f "${ED}"/usr/share/man/man1/peekfd.1
}
