# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/usbutils/Attic/usbutils-003.ebuild,v 1.2 2011/08/24 17:35:46 radhermit Exp $

EAPI="4"

PYTHON_DEPEND="python? 2:2.6"

inherit python rpm lts6-rpm

DESCRIPTION="USB enumeration utilities"
HOMEPAGE="http://linux-usb.sourceforge.net/"
SRPM="usbutils-003-4.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="network-cron python zlib"

RDEPEND="virtual/libusb:1
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	# Notes on Patch1: usbutils-003-invalid-config-descriptors.patch
	# https://bugzilla.redhat.com/show_bug.cgi?id=707853
	# "[abrt] usbutils-001-3.fc15: find_otg: Process /usr/bin/lsusb was killed by
	# signal 11 (SIGSEGV)"
	# sent to upstream (Greg KH) via email and github pull request
	SRPM_PATCHLIST="Patch0: usbutils-003-hwdata.patch
			Patch1: usbutils-003-invalid-config-descriptors.patch
			Patch2: usbutils-003-man-usbids.patch"
	lts6_srpm_epatch || die

	if use python; then
		python_convert_shebangs 2 lsusb.py
		sed -i -e '/^usbids/s:/usr/share:/usr/share/misc:' lsusb.py || die
	fi
}

src_configure() {
	econf \
		--datarootdir=/usr/share \
		--datadir=/usr/share/misc \
		$(use_enable zlib)
}

src_install() {
	emake DESTDIR="${D}" install || die
	use python || rm -f "${D}"/usr/bin/lsusb.py
	mv "${D}"/usr/sbin/update-usbids{.sh,} || die
	newbin "${FILESDIR}"/usbmodules.sh usbmodules || die
	dodoc AUTHORS ChangeLog NEWS README

	use network-cron || return 0
	exeinto /etc/cron.monthly
	newexe "${FILESDIR}"/usbutils.cron update-usbids || die
}
