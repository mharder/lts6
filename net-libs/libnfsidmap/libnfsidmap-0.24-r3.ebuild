# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libnfsidmap/libnfsidmap-0.24.ebuild,v 1.6 2012/02/04 19:00:36 armin76 Exp $

EAPI="4"

inherit autotools rpm lts6-rpm

DESCRIPTION="NFSv4 ID <-> name mapping library"
HOMEPAGE="http://www.citi.umich.edu/projects/nfsv4/linux/"
SRPM="nfs-utils-lib-1.1.5-4.el6.src.rpm"
SRPM_SUB_PKG="${PN}-${PV}.tar.gz"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="ldap static-libs"

DEPEND="ldap? ( net-nds/openldap )"
RDEPEND="${DEPEND}
	!<net-fs/nfs-utils-1.2.2
	!net-fs/idmapd"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${SRPM_SUB_PKG}" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch01: nfs-utils-lib-1.1.5-libnfsidmap-0-25-rc1.patch
			Patch02: nfs-utils-lib-1.1.5-ldapsupport.patch
			Patch100: nfs-utils-lib-rhel-idmapd.conf-default.patch
			Patch102: nfs-utils-lib-1.1.5-compile.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-0.19-getgrouplist.patch #169909
	epatch "${FILESDIR}"/${PN}-0.21-headers.patch
	epatch "${FILESDIR}"/${PN}-0.24-adapt-to-EL-config.patch
	eautoreconf
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable ldap)
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README

	insinto /etc
	doins idmapd.conf || die

	# remove useless files
	rm -f "${D}"/usr/lib*/libnfsidmap/*.{a,la}
	use static-libs || rm -f "${D}"/usr/lib*/*.la
}
