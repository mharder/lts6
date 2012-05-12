# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man-pages-posix/man-pages-posix-2003a.ebuild,v 1.13 2010/03/29 23:24:25 abcd Exp $

EAPI=4

inherit eutils rpm lts6-rpm

MY_P="${PN}-${PV:0:4}-${PV:0-1}"
DESCRIPTION="POSIX man-pages (0p, 1p, 3p)"
HOMEPAGE="http://www.kernel.org/doc/man-pages/"

SRPM="man-pages-3.22-17.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"

LICENSE="man-pages-posix"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE=""
RESTRICT="mirror binchecks"

RDEPEND="virtual/man !<sys-apps/man-pages-3"

S=${WORKDIR}/${MY_P}

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./man-pages-posix-2003-a.tar.bz2" || die "unpack failed!"
}

src_prepare() {
	epatch "${FILESDIR}"/man-pages-2.08-updates.patch
}

src_configure() { :; }

src_compile() { :; }

src_install() {
	emake install DESTDIR="${ED}" || die
	dodoc man-pages-*.Announce README Changes*
}