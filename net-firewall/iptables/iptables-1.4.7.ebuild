# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-firewall/iptables/Attic/iptables-1.4.7.ebuild,v 1.4 2011/06/16 12:53:26 pva dead $

EAPI="4"

# Force users doing their own patches to install their own tools
AUTOTOOLS_AUTO_DEPEND=no

inherit autotools eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Linux kernel (2.4+) firewall, NAT and packet mangling tools"
HOMEPAGE="http://www.iptables.org/"
SRC_URI="http://iptables.org/projects/iptables/files/${P}.tar.bz2"

SRPM="iptables-1.4.7-5.1.el6_2.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="ipv6"

DEPEND="virtual/os-headers"
RDEPEND=""

src_prepare() {
	SRPM_PATCHLIST="Patch5: iptables-1.4.5-cloexec.patch
			Patch6: iptables-1.4.7-xt_CHECKSUM.patch
			Patch7: iptables-1.4.7-tproxy.patch
			Patch8: iptables-1.4.7-xt_AUDIT_v2.patch
			Patch9: iptables-1.4.7-opt_parser_v2.patch"
	lts6_srpm_epatch || die

	# Only run autotools if user patched something
	epatch_user && eautoreconf || elibtoolize
}

src_configure() {
	econf \
		--sbindir=/sbin \
		--libexecdir=/$(get_libdir) \
		--enable-devel \
		--enable-libipq \
		--enable-shared \
		--enable-static \
		$(use_enable ipv6)
}

src_compile() {
	emake V=1 || die
}

src_install() {
	emake install DESTDIR="${D}" || die
	dosbin iptables-apply
	doman iptables-apply.8
	dodoc COMMIT_NOTES INCOMPATIBILITIES iptables.xslt

	insinto /usr/include
	doins include/iptables.h $(use ipv6 && echo include/ip6tables.h) || die
	insinto /usr/include/iptables
	doins include/iptables/internal.h || die

	keepdir /var/lib/iptables
	newinitd "${FILESDIR}"/${PN}-1.4.13.init iptables
	newconfd "${FILESDIR}"/${PN}-1.4.13.confd iptables
	if use ipv6 ; then
		keepdir /var/lib/ip6tables
		newinitd "${FILESDIR}"/iptables-1.4.13.init ip6tables
		newconfd "${FILESDIR}"/ip6tables-1.4.13.confd ip6tables
	fi

	find "${ED}" -type f -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}
