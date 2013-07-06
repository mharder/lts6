# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/make/make-3.81-r2.ebuild,v 1.10 2012/05/24 02:38:35 vapier Exp $

inherit flag-o-matic eutils rpm lts6-rpm

DESCRIPTION="Standard tool to compile source trees"
HOMEPAGE="http://www.gnu.org/software/make/make.html"
SRPM="make-3.81-20.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls static"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

SRPM_PATCHLIST="
Patch: make-3.79.1-noclock_gettime.patch
Patch4: make-3.80-j8k.patch
Patch5: make-3.80-getcwd.patch
Patch6: make-3.81-err-reporting.patch
Patch7: make-3.81-memory.patch
Patch8: make-3.81-rlimit.patch
Patch9: make-3.81-newlines.patch
Patch10: make-3.81-jobserver.patch
Patch11: make-3.81-fdleak.patch
Patch12: make-3.81-strcpy-overlap.patch
Patch13: make-3.81-recursion-test.patch
Patch14: make-3.81-copy-on-expand.patch
"

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"

	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${P}-tests-lang.patch
	epatch "${FILESDIR}"/${P}-long-cmdline-lts6.patch #301116
	# The following two patches are in the srpm patch set
	# epatch "${FILESDIR}"/${P}-tests-recursion.patch #329153
	# epatch "${FILESDIR}"/${P}-jobserver.patch #193258
}

src_compile() {
	use static && append-ldflags -static
	econf \
		$(use_enable nls) \
		--program-prefix=g \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README*
	if [[ ${USERLAND} == "GNU" ]] ; then
		# we install everywhere as 'gmake' but on GNU systems,
		# symlink 'make' to 'gmake'
		dosym gmake /usr/bin/make
		dosym gmake.1 /usr/share/man/man1/make.1
	fi
}
