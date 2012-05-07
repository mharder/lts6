# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.25.ebuild,v 1.11 2011/10/30 05:18:43 mattst88 Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"

SRPM="libdrm-2.4.25-2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
VIDEO_CARDS="intel nouveau radeon vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )"
DEPEND="${RDEPEND}
	>=x11-libs/libpciaccess-0.10"

PATCHES=(
	"${FILESDIR}"/${PN}-2.4.23-solaris.patch
)

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch3: libdrm-make-dri-perms-okay.patch
			Patch4: libdrm-2.4.0-no-bc.patch"
	lts6_srpm_epatch || die

	xorg-2_src_prepare
}

pkg_setup() {
	CONFIGURE_OPTIONS="--enable-udev
		$(use_enable video_cards_intel intel)
		$(use_enable video_cards_nouveau nouveau-experimental-api)
		$(use_enable video_cards_radeon radeon)
		$(use_enable video_cards_vmware vmwgfx-experimental-api)
		$(use_enable libkms)"

	xorg-2_pkg_setup
}
