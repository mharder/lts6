# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/hwdata-redhat/hwdata-redhat-0.217.ebuild,v 1.3 2012/02/25 06:45:07 robbat2 Exp $

EAPI="5"

inherit eutils flag-o-matic rpm

DESCRIPTION="Hardware identification and configuration data"
HOMEPAGE="http://fedora.redhat.com/projects/config-tools/"

SRPM="hwdata-0.233-7.9.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~ppc ~ppc64 ~x86 ~amd64"
IUSE="test"
RDEPEND="virtual/modutils
	!sys-apps/hwdata-gentoo"
DEPEND="${RDEPEND}
	test? ( sys-apps/pciutils )"

S="${WORKDIR}/hwdata-${PV}"

src_prepare() {
	sed -i -e "s:\(/sbin\/lspci\):/usr\1:g" Makefile || die
	epatch "${FILESDIR}/${PN}-0.217-python-3.patch"
	epatch "${FILESDIR}/hwdata-remove-blacklist.patch"
}

# src_install() {
#	emake DESTDIR="${D}" install || die "emake install failed"
#	# Don't let it overwrite a udev-installed file
#	rm -rf "${D}"/etc/ || die
#}
