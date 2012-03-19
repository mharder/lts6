# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/acl/acl-2.2.49-r1.ebuild,v 1.1 2011/04/15 17:08:47 flameeyes Exp $

EAPI=4

inherit eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="access control list utilities, libraries and headers"
HOMEPAGE="http://savannah.nongnu.org/projects/acl"
SRPM="acl-2.2.49-6.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	nfs? ( http://www.citi.umich.edu/projects/nfsv4/linux/acl-patches/2.2.42-2/acl-2.2.42-CITI_NFS4_ALL-2.dif )"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="nfs nls static-libs"

RDEPEND=">=sys-apps/attr-2.4
	nfs? ( net-libs/libnfsidmap )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"

	if use nfs ; then
		cp "${DISTDIR}"/acl-2.2.42-CITI_NFS4_ALL-2.dif . || die
		sed -i \
			-e '/^diff --git a.debian.changelog b.debian.changelog/,/^diff --git/d' \
			acl-2.2.42-CITI_NFS4_ALL-2.dif || die
		epatch acl-2.2.42-CITI_NFS4_ALL-2.dif
	fi
	epatch "${FILESDIR}"/${P}-quote-strchr.patch
	sed -i \
		-e '/^as_dummy=/s:=":="$PATH$PATH_SEPARATOR:' \
		configure # hack PATH with AC_PATH_PROG
	sed -i \
		-e "/^PKG_DOC_DIR/s:@pkg_name@:${PF}:" \
		-e '/HAVE_ZIPPED_MANPAGES/s:=.*:=false:' \
		include/builddefs.in \
		|| die "failed to update builddefs"
	strip-linguas po

	SRPM_PATCHLIST="Patch0: acl-2.2.3-multilib.patch
			Patch2: acl-2.2.49-setfacl-walk.patch
			Patch3: acl-2.2.49-bz467936.patch
			Patch4: acl-2.2.49-tests.patch
			Patch5: acl-2.2.49-setfacl-restore.patch
			Patch6: acl-2.2.49-bz658734.patch"
	lts6_srpm_epatch || die

	# Patch7: acl-2.2.49-bz720318.patch is structured in a way
	# that fails when tested, so apply a reconstructed equivilant
	# patch.
	epatch "${FILESDIR}/${P}-bz720318-restructured.patch"
}

src_configure() {
	unset PLATFORM #184564
	export OPTIMIZER=${CFLAGS}
	export DEBUG=-DNDEBUG

	econf \
		$(use_enable nls gettext) \
		--enable-shared $(use_enable static-libs static) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir) \
		--bindir="${EPREFIX}"/bin
}

src_install() {
	emake DIST_ROOT="${D}" install install-dev install-lib || die
	use static-libs || find "${D}" -name '*.la' -delete

	# move shared libs to /
	gen_usr_ldscript -a acl
}
