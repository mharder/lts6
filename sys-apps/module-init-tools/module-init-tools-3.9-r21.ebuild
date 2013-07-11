# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/module-init-tools/Attic/module-init-tools-3.9.ebuild,v 1.4 2012/11/24 21:14:02 ssuominen dead $

EAPI="4"
inherit eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="Tools for managing linux kernel modules"
HOMEPAGE="http://modules.wiki.kernel.org/"
SRC_URI="mirror://kernel/linux/utils/kernel/module-init-tools/${P}.tar.bz2"

SRPM="module-init-tools-3.9-21.el6_4.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="static"

DEPEND="sys-libs/zlib"
RDEPEND="${DEPEND}
	!<sys-apps/baselayout-2.0.1
	!sys-apps/kmod
	!sys-apps/modutils"

SRPM_PATCHLIST="
Patch0: module-init-tools-overrides.patch
Patch1: module-init-tools-show-depends-commands.patch
Patch2: module-init-tools-fix-gzipped-module-handling-in-depmod.patch
Patch3: module-init-tools-empty-overrides.patch
Patch4: reduce-memory-consumption.patch
Patch5: version-check.patch
Patch6: module-init-tools-rhbz972588.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-3.2.2-handle-dupliate-aliases.patch #149426
	touch *.5 *.8 # dont regen manpages
}

src_configure() {
	use static && append-ldflags -static
	econf \
		--prefix=/ \
		--enable-zlib \
		--enable-zlib-dynamic \
		--disable-static-utils
}

src_test() {
	./tests/runtests || die
}

src_install() {
	emake install DESTDIR="${D}"
	dodoc AUTHORS ChangeLog NEWS README TODO

	into /
	newsbin "${FILESDIR}"/update-modules-3.5.sh update-modules
	doman "${FILESDIR}"/update-modules.8

	into /sbin
	dosbin "${WORKDIR}/weak-modules"

	insinto /etc/modprobe.d
	newins "${WORKDIR}/modprobe-dist.conf" dist.conf
	newins "${WORKDIR}/modprobe-dist-oss.conf" dist-oss.conf
	newins "${WORKDIR}/modprobe-dist-alsa.conf" dist-alsa.conf
}

pkg_postinst() {
	# cheat to keep users happy
	if grep -qs modules-update "${ROOT}"/etc/init.d/modules ; then
		sed -i 's:modules-update:update-modules:' "${ROOT}"/etc/init.d/modules
	fi
}
