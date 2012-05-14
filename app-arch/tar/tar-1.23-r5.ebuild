# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/tar/tar-1.23-r4.ebuild,v 1.2 2012/03/04 15:35:15 klausman Exp $

EAPI="4"

inherit autotools flag-o-matic eutils rpm lts6-rpm

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="http://www.gnu.org/software/tar/"
SRPM="tar-1.23-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="nls static userland_GNU +xattr"

RDEPEND="xattr? (
		sys-apps/attr
		virtual/acl
	)"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.10.35 )"

src_prepare() {
	SRPM_PATCHLIST="Patch1: tar-1.14-loneZeroWarning.patch
			Patch2: tar-1.15.1-vfatTruncate.patch"
	lts6_srpm_epatch || die

	if use xattr ; then
		SRPM_PATCHLIST="Patch3: tar-1.23-xattrs.patch"
		lts6_srpm_epatch || die
	fi

	SRPM_PATCHLIST="Patch4: tar-1.17-wildcards.patch
			Patch5: tar-1.22-atime-rofs.patch
			Patch6: tar-1.22-fortifysourcessigabrt.patch
			Patch7: tar-1.23-oldarchive.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${P}-revert-pipe.patch #309001
	# The strncpy patch is the same as the EL patch:
	# tar-1.22-fortifysourcessigabrt.patch
	# epatch "${FILESDIR}"/${P}-strncpy.patch #317139
	epatch "${FILESDIR}"/${P}-symlink-k-hang.patch #327641
	epatch "${FILESDIR}"/${P}-tests.patch #326785

	if ! use userland_GNU ; then
		sed -i \
			-e 's:/backup\.sh:/gbackup.sh:' \
			scripts/{backup,dump-remind,restore}.in \
			|| die "sed non-GNU"
	fi

	# The xattr patch modifies Makefile.am
	if use xattr ; then
		eautoreconf
	fi
}

src_configure() {
	local myconf
	use static && append-ldflags -static
	use userland_GNU || myconf="--program-prefix=g"
	# Work around bug in sandbox #67051
	gl_cv_func_chown_follows_symlink=yes \
	econf \
		--enable-backup-scripts \
		--bindir=/bin \
		--libexecdir=/usr/sbin \
		$(use_enable nls) \
		${myconf}
}

src_install() {
	local p=""
	use userland_GNU || p=g

	emake DESTDIR="${D}" install || die "make install failed"

	if [[ -z ${p} ]] ; then
		# a nasty yet required piece of baggage
		exeinto /etc
		doexe "${FILESDIR}"/rmt || die
	fi

	# autoconf looks for gtar before tar (in configure scripts), hence
	# in Prefix it is important that it is there, otherwise, a gtar from
	# the host system (FreeBSD, Solaris, Darwin) will be found instead
	# of the Prefix provided (GNU) tar
	if use prefix ; then
		dosym tar /bin/gtar
	fi

	dodoc AUTHORS ChangeLog* NEWS README* THANKS
	newman "${WORKDIR}"/tar.1 ${p}tar.1
	mv "${ED}"/usr/sbin/${p}backup{,-tar}
	mv "${ED}"/usr/sbin/${p}restore{,-tar}

	rm -f "${D}"/usr/$(get_libdir)/charset.alias
}
