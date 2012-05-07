# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-video-intel/xf86-video-intel-2.16.0.ebuild,v 1.1 2011/08/11 15:51:43 chithanh Exp $

EAPI=4

XORG_DRI=dri
inherit linux-info xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org driver for Intel cards"

KEYWORDS="~amd64 ~ia64 ~x86 -x86-fbsd"
IUSE="sna"

SRPM="xorg-x11-drv-intel-2.16.0-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXvMC
	>=x11-libs/libxcb-1.5
	>=x11-libs/libdrm-2.4.23[video_cards_intel]
	sna? (
		>=x11-base/xorg-server-1.10
	)"
DEPEND="${RDEPEND}
	>=x11-proto/dri2proto-2.3"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: dri2proto-hack.patch
			Patch22: intel-2.11.0-vga-clock-max.patch"
	lts6_srpm_epatch || die

	eautoreconf
}

pkg_setup() {
	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable dri)
		$(use_enable sna)
		--enable-xvmc
	)
}

pkg_postinst() {
	if linux_config_exists \
		&& ! linux_chkconfig_present DRM_I915_KMS; then
		echo
		ewarn "This driver requires KMS support in your kernel"
		ewarn "  Device Drivers --->"
		ewarn "    Graphics support --->"
		ewarn "      Direct Rendering Manager (XFree86 4.1.0 and higher DRI support)  --->"
		ewarn "      <*>   Intel 830M, 845G, 852GM, 855GM, 865G (i915 driver)  --->"
		ewarn "              i915 driver"
		ewarn "      [*]       Enable modesetting on intel by default"
		echo
	fi
}
