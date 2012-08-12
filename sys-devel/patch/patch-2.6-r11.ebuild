# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/patch/Attic/patch-2.6.ebuild,v 1.1 2009/11/14 15:33:39 vapier Exp $

EAPI="4"

inherit flag-o-matic rpm lts6-rpm

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"

SRPM="patch-2.6-6.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="selinux static test"

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( sys-apps/ed )"

src_unpack() {
	# Explicit support for xz archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.xz" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch1: patch-2.5.4-sigsegv.patch
			Patch2: patch-best-name.patch
			Patch3: patch-get-arg.patch"
	lts6_srpm_epatch || die

	if use selinux; then
		SRPM_PATCHLIST="Patch100: patch-selinux.patch"
		lts6_srpm_epatch || die
	fi
}

src_configure() {
	use static && append-ldflags -static

	local myconf=""
	[[ ${USERLAND} != "GNU" ]] && myconf="--program-prefix=g"
	econf ${myconf}
}

src_install() {
	emake DESTDIR="${ED}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
