# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/rsync/Attic/rsync-3.0.6.ebuild,v 1.9 2009/10/20 08:33:14 vapier Exp $

EAPI="4"

inherit eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="http://rsync.samba.org/"
SRPM="rsync-3.0.6-9.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-fbsd ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="acl iconv ipv6 static xattr"

DEPEND=">=dev-libs/popt-1.5
	acl? ( virtual/acl )
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	iconv? ( virtual/libiconv )"

# S=${WORKDIR}/${P/_/}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: rsync-3.0.6-permissions.patch
			Patch1: rsync-3.0.6-CVE-2011-1097.patch
			Patch2: rsync-3.0.6-ftrunc-sparse-files.patch
			Patch3: rsync-3.0.6-inflate-ret.patch"
	lts6_srpm_epatch || die

	epatch_user
}

src_configure() {
	use static && append-ldflags -static
	econf \
		--without-included-popt \
		$(use_enable acl acl-support) \
		$(use_enable xattr xattr-support) \
		$(use_enable ipv6) \
		$(use_enable iconv) \
		--with-rsyncd-conf=/etc/rsyncd.conf \
		|| die
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	newconfd "${FILESDIR}"/rsyncd.conf.d rsyncd
	newinitd "${FILESDIR}"/rsyncd.init.d rsyncd
	dodoc NEWS OLDNEWS README TODO tech_report.tex
	insinto /etc
	doins "${FILESDIR}"/rsyncd.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/rsyncd.logrotate rsyncd

	insinto /etc/xinetd.d
	newins "${FILESDIR}"/rsyncd.xinetd rsyncd

	# Install the useful contrib scripts
	exeinto /usr/share/rsync
	doexe support/*
	rm -f "${ED}"/usr/share/rsync/{Makefile*,*.c}
}

pkg_postinst() {
	if egrep -qs '^[[:space:]]use chroot[[:space:]]*=[[:space:]]*(no|0|false)' \
		"${ROOT}"/etc/rsyncd.conf "${ROOT}"/etc/rsync/rsyncd.conf ; then
		ewarn "You have disabled chroot support in your rsyncd.conf.  This"
		ewarn "is a security risk which you should fix.  Please check your"
		ewarn "/etc/rsyncd.conf file and fix the setting 'use chroot'."
	fi
}
