# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/gzip/Attic/gzip-1.3.12-r1.ebuild,v 1.7 2008/04/13 22:55:54 vapier Exp $

EAPI="4"

inherit eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="Standard GNU compressor"
HOMEPAGE="http://www.gnu.org/software/gzip/"

SRPM="gzip-1.3.12-18.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="nls pic static"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SRPM_PATCHLIST="
Patch0: gzip-1.3.12-openbsd-owl-tmp.patch
Patch1: gzip-1.3.5-zforce.patch
Patch3: gzip-1.3.9-stderr.patch
Patch4: gzip-1.3.10-zgreppipe.patch
Patch5: gzip-1.3.9-rsync.patch
Patch7: gzip-1.3.9-addsuffix.patch
Patch14: gzip-1.3.5-cve-2006-4338.patch
Patch15: gzip-1.3.9-cve-2006-4337.patch
Patch16: gzip-1.3.5-cve-2006-4337_len.patch
Patch17: gzip-1.3.12-futimens.patch
Patch18: gzip-1.3.12-zdiff.patch
# Fixed in upstream 1.3.13
Patch19: gzip-1.3.12-close-stdout.patch
Patch20: gzip-1.3.12-cve-2010-0001.patch
Patch21: gzip-1.3.12-cve-2009-2624.patch
Patch22: gzip-1.3.13-noemptysuffix.patch
Patch23: gzip-1.3.13-crc-error.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	# Use EL gzip-1.3.12-futimens.patch
	# epatch "${FILESDIR}"/gnulib-futimens-rename.patch
	epatch "${FILESDIR}"/${PN}-1.3.8-install-symlinks.patch
}

src_configure() {
	use static && append-flags -static
	# avoid text relocation in gzip
	use pic && export DEFS="NO_ASM"
	econf $(use_enable nls) || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README THANKS TODO
	docinto txt
	dodoc algorithm.doc gzip.doc

	# keep most things in /usr, just the fun stuff in /
	dodir /bin
	mv "${D}"/usr/bin/{gunzip,gzip,uncompress,zcat} "${D}"/bin/ || die
	sed -e 's:/usr::' -i "${D}"/bin/gunzip || die
}
