# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/sysfsutils/sysfsutils-2.1.0.ebuild,v 1.11 2010/11/19 17:45:25 jlec Exp $

EAPI="3"

inherit toolchain-funcs eutils rpm lts6-rpm

DESCRIPTION="System Utilities Based on Sysfs"
HOMEPAGE="http://linux-diag.sourceforge.net/Sysfsutils.html"

SRPM="sysfsutils-2.1.0-6.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE=""

SRPM_PATCHLIST="
# Skip the redhatify patch, leave license locations at default.
# Patch0:         sysfsutils-2.0.0-redhatify.patch
Patch1:         sysfsutils-2.0.0-class-dup.patch
Patch2:         sysfsutils-2.1.0-get_link.patch
"

src_unpack() {
	rpm_src_unpack || die
	epunt_cxx
}

src_prepare() {
	lts6_srpm_epatch || die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS CREDITS ChangeLog NEWS README TODO docs/libsysfs.txt || die
	gen_usr_ldscript -a sysfs

	# We do not distribute this
	rm -f "${ED}"/usr/bin/dlist_test "${ED}"/usr/lib*/libsysfs.la || die
}
