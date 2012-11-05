# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/randrproto/randrproto-1.4.0.ebuild,v 1.1 2012/07/12 13:40:06 chithanh Exp $

EAPI="4"
inherit autotools xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org Randr protocol headers"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

LOCAL_PV="20110224-git105a161"
SRPM="xorg-x11-proto-devel-7.6-13.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
SRPM_PROTO_PKG="${PN}-${LOCAL_PV}.tar.bz2"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${LOCAL_PV}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${SRPM_PROTO_PKG}" || die "unpack failed!"
}

src_prepare(){
	eautoreconf
}
