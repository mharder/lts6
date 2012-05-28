# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/Attic/cpio-2.10-r1.ebuild,v 1.8 2010/10/10 00:03:38 vapier dead $

EAPI=2

inherit eutils rpm lts6-rpm

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"

SRPM="cpio-2.10-10.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls"

SRPM_PATCHLIST="
#We use SVR4 portable format as default .
Patch1: cpio-2.9-rh.patch
#fix warn_if_file_changed() and set exit code to 1 when cpio
# fails to store file > 4GB (#183224)
Patch2: cpio-2.9-exitCode.patch
#when extracting archive created with 'find -depth',
# restore the permissions of directories properly (bz#430835)
Patch3: cpio-2.9-dir_perm.patch
#Support major/minor device numbers over 127 (bz#450109)
Patch4: cpio-2.9-dev_number.patch
#make -d honor system umask(#484997)
Patch5: cpio-2.9-sys_umask.patch
#define default remote shell as /usr/bin/ssh(#452904)
Patch6: cpio-2.9.90-defaultremoteshell.patch
#do not fail with new POSIX 2008 utimens() glibc call(#552320)
Patch7: cpio-2.10-utimens.patch
#fix segfault with nonexisting file with patternnames(#567022)
Patch8: cpio-2.10-patternnamesigsegv.patch
# CVE-2010-0624 fix heap-based buffer overflow by expanding
# a specially-crafted archive(#571843)
Patch9: cpio-2.10-rtapeliboverflow.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	# Per here: http://lists.gnu.org/archive/html/bug-cpio/2009-10/msg00000.html
	# fixes hardlink creation from XFS
	epatch "${FILESDIR}"/cpio-2.9-64-bit-wide-inode-fixup.patch

	# Use the more extensive man page provided in the EL SRPM
	cp "${WORKDIR}/cpio.1" "${S}/doc"
}

src_configure() {
	econf \
		$(use_enable nls) \
		--bindir=/bin \
		--with-rmt=/usr/sbin/rmt \
		|| die
}

src_compile() {
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README
	rm -f "${D}"/usr/share/man/man1/mt.1
	rmdir "${D}"/usr/libexec || die
}
