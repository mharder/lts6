# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/reiserfsprogs/reiserfsprogs-3.6.21-r1.ebuild,v 1.7 2012/02/13 10:04:17 xarthisius Exp $

EAPI=4
inherit eutils rpm lts6-rpm

DESCRIPTION="Reiserfs Utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/fs/reiserfs/"
SRPM="reiserfs-utils-3.6.21-1.el6.elrepo.src.rpm"
SRC_URI="mirror://elrepo/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 -sparc ~x86"
IUSE=""

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${P}-fsck-n.patch
	epatch "${FILESDIR}"/${P}-fix_large_fs.patch
}

src_configure() {
	econf --prefix=/ || die "Failed to configure"
}

src_install() {
	emake DESTDIR="${D}" install || die "Failed to install"
	dosym reiserfsck /sbin/fsck.reiserfs
	dosym mkreiserfs /sbin/mkfs.reiserfs
	dodoc ChangeLog INSTALL README
}
