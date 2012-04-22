# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/attr/attr-2.4.44-r1.ebuild,v 1.2 2011/05/16 20:34:44 vapier Exp $

EAPI="4"

inherit eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Extended attributes tools"
HOMEPAGE="http://savannah.nongnu.org/projects/attr"
SRPM="attr-2.4.44-7.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="nls static-libs"

DEPEND="nls? ( sys-devel/gettext )
	sys-devel/autoconf"
RDEPEND=""

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.4.44-gettext.patch
	epatch "${FILESDIR}"/${P}-headers.patch
	sed -i \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	strip-linguas -u po

	SRPM_PATCHLIST="Patch1: attr-2.2.0-multilib.patch
			Patch2: attr-2.4.32-build.patch
			Patch3: attr-2.4.43-leak.patch
			Patch4: attr-2.4.44-tests.patch
			Patch5: attr-bz599562.patch
			Patch6: attr-bz651119.patch
			Patch7: attr-bz665050.patch
			Patch8: attr-bz674870.patch
			Patch9: attr-bz665049.patch"
	lts6_srpm_epatch || die
}

src_configure() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--enable-shared $(use_enable static-libs static) \
		--libexecdir=/usr/$(get_libdir) \
		--bindir=/bin
}

src_install() {
	emake DIST_ROOT="${D}" install install-lib install-dev || die
	use static-libs || find "${D}" -name '*.la' -delete
	# the man-pages packages provides the man2 files
	rm -r "${D}"/usr/share/man/man2

	# we install attr into /bin, so we need the shared lib with it
	gen_usr_ldscript -a attr
}
