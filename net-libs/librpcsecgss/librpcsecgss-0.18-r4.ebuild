# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/librpcsecgss/librpcsecgss-0.19-r1.ebuild,v 1.1 2010/07/27 10:02:30 flameeyes Exp $

EAPI="4"

inherit rpm lts6-rpm

DESCRIPTION="implementation of rpcsec_gss (RFC 2203) for secure rpc communication"
HOMEPAGE="http://www.citi.umich.edu/projects/nfsv4/linux/"
SRPM="nfs-utils-lib-1.1.5-4.el6.src.rpm"
SRPM_SUB_PKG="${PN}-${PV}.tar.gz"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

RDEPEND="net-libs/libgssglue"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${SRPM_SUB_PKG}" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch00: nfs-utils-lib-changelicensetoBSD.patch
			Patch101: nfs-utils-lib-1.1.5-warnings.patch"
	lts6_srpm_epatch || die
}

src_configure() {
	# No need to install static libraries, as it uses non-static dependencies
	econf --disable-static
}

src_install() {
	emake install DESTDIR="${D}" || die
	find "${D}" -name '*.la' -delete || die

	dodoc AUTHORS ChangeLog NEWS README
}
