# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-drivers/xf86-input-evdev/xf86-input-evdev-2.6.0.ebuild,v 1.7 2011/03/05 18:09:14 xarthisius Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="Generic Linux input driver"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86"
IUSE=""

# The EL SRPM has a fdi file to provide hal support provided in evdev,
# but hal support is not currently supported in the lts6 overlay.
# IUSE="hal"

SRPM="xorg-x11-drv-evdev-${PV}-2.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=">=x11-base/xorg-server-1.6.3"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-2.6
	x11-misc/xkeyboard-config
	x11-proto/inputproto
	x11-proto/xproto"

SRPM_PATCHLIST="
# 618845 - Laptop monitor is activated when notebook lid is closed
Patch005:   evdev-2.6.0-lid.patch
# Revert MB changes from upstream, ship with RHEL 6 defaults
Patch006:   evdev-2.6.0-revert-mb-emu-changes.patch
# Avoid log closure on PreInit failure
Patch007:   evdev-2.6.0-Always-reset-the-fd-to-1.patch
"

src_prepare() {
	lts6_srpm_epatch || die
}
