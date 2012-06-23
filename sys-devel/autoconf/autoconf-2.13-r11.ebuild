# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/autoconf/autoconf-2.13.ebuild,v 1.20 2012/04/26 17:57:01 aballier Exp $

inherit eutils rpm lts6-rpm

DESCRIPTION="Used to create autoconfiguration files"
HOMEPAGE="http://www.gnu.org/software/autoconf/autoconf.html"

SRPM="autoconf213-2.13-20.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE=""

DEPEND=">=sys-apps/texinfo-4.3
	sys-devel/autoconf-wrapper
	=sys-devel/m4-1.4*
	dev-lang/perl"
RDEPEND="${DEPEND}"

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"

	SRPM_PATCHLIST="Patch0:     autoconf-2.12-race.patch
			Patch1:     autoconf-2.13-mawk.patch
			Patch2:     autoconf-2.13-notmp.patch
			Patch3:     autoconf-2.13-c++exit.patch
			Patch4:     autoconf-2.13-headers.patch
			Patch5:     autoconf-2.13-autoscan.patch
			Patch6:     autoconf-2.13-exit.patch
			Patch7:     autoconf-2.13-wait3test.patch
			Patch8:     autoconf-2.13-make-defs-62361.patch
			# The following three patches implement
			# autoconf-2.13 slotting in a manner that conflicts
			# with the considerations already in the
			# ebuild.
			# Patch9:     autoconf-2.13-versioning.patch
			# Patch10:    autoconf213-destdir.patch
			# Patch11:    autoconf213-info.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${P}-gentoo.patch
	epatch "${FILESDIR}"/${P}-destdir.patch
	epatch "${FILESDIR}"/${P}-test-fixes.patch #146592
	touch configure # make sure configure is newer than configure.in

	rm -f standards.{texi,info} # binutils installs this infopage

	sed -i \
		-e 's|\* Autoconf:|\* Autoconf v2.1:|' \
		-e '/START-INFO-DIR-ENTRY/ i INFO-DIR-SECTION GNU programming tools' \
		autoconf.texi \
		|| die "sed failed"
}

src_compile() {
	# need to include --exec-prefix and --bindir or our
	# DESTDIR patch will trigger sandbox hate :(
	#
	# need to force locale to C to avoid bugs in the old
	# configure script breaking the install paths #351982
	LC_ALL=C \
	econf \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--program-suffix="-${PV}" \
		|| die
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	dodoc AUTHORS NEWS README TODO ChangeLog ChangeLog.0 ChangeLog.1

	mv "${D}"/usr/share/info/autoconf{,-${PV}}.info
}
