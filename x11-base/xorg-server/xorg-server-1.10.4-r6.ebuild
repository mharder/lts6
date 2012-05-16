# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-server/xorg-server-1.10.4-r1.ebuild,v 1.4 2011/10/22 16:57:28 xarthisius Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 multilib versionator rpm lts6-rpm

DESCRIPTION="X.Org X servers"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"

SRPM="xorg-x11-server-1.10.4-6.sl6.3.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

IUSE_SERVERS="dmx kdrive xnest xorg xvfb"
IUSE="${IUSE_SERVERS} ipv6 minimal nptl tslib +udev"

RDEPEND=">=app-admin/eselect-opengl-1.0.8
	dev-libs/openssl
	media-libs/freetype
	>=x11-apps/iceauth-1.0.2
	>=x11-apps/rgb-1.0.3
	>=x11-apps/xauth-1.0.2
	x11-apps/xkbcomp
	>=x11-libs/libpciaccess-0.8.0
	>=x11-libs/libXau-1.0.4
	>=x11-libs/libXdmcp-1.0.2
	>=x11-libs/libXfont-1.4.1
	>=x11-libs/libxkbfile-1.0.4
	>=x11-libs/pixman-0.15.20
	>=x11-libs/xtrans-1.2.2
	>=x11-misc/xbitmaps-1.0.1
	>=x11-misc/xkeyboard-config-1.4
	dmx? (
		x11-libs/libXt
		>=x11-libs/libdmx-1.0.99.1
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXaw-1.0.4
		>=x11-libs/libXext-1.0.99.4
		>=x11-libs/libXfixes-4.0.3
		>=x11-libs/libXi-1.2.99.1
		>=x11-libs/libXmu-1.0.3
		>=x11-libs/libXres-1.0.3
		>=x11-libs/libXtst-1.0.99.2
	)
	kdrive? (
		>=x11-libs/libXext-1.0.5
		x11-libs/libXv
	)
	!minimal? (
		>=x11-libs/libX11-1.1.5
		>=x11-libs/libXext-1.0.5
		>=media-libs/mesa-7.8_rc[nptl=]
	)
	tslib? ( >=x11-libs/tslib-1.0 x11-proto/xcalibrateproto )
	udev? ( >=sys-fs/udev-143 )
	>=x11-apps/xinit-1.3"

# dmx+doc DEPEND is a hack, a proper solution needs to be implemented in the
# xorg-2.eclass for next release
DEPEND="${RDEPEND}
	sys-devel/flex
	>=x11-proto/bigreqsproto-1.1.0
	>=x11-proto/compositeproto-0.4
	>=x11-proto/damageproto-1.1
	>=x11-proto/fixesproto-4.1
	>=x11-proto/fontsproto-2.0.2
	>=x11-proto/glproto-1.4.11
	>=x11-proto/inputproto-1.9.99.902
	>=x11-proto/kbproto-1.0.3
	>=x11-proto/randrproto-1.2.99.3
	>=x11-proto/recordproto-1.13.99.1
	>=x11-proto/renderproto-0.11
	>=x11-proto/resourceproto-1.0.2
	>=x11-proto/scrnsaverproto-1.1
	>=x11-proto/trapproto-3.4.3
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcmiscproto-1.2.0
	>=x11-proto/xextproto-7.1.99
	>=x11-proto/xf86dgaproto-2.0.99.1
	>=x11-proto/xf86rushproto-1.1.2
	>=x11-proto/xf86vidmodeproto-2.2.99.1
	>=x11-proto/xineramaproto-1.1.3
	>=x11-proto/xproto-7.0.17
	dmx? (
		>=x11-proto/dmxproto-2.2.99.1
		doc? (
			|| (
				www-client/links
				www-client/lynx
				www-client/w3m
			)
		)
	)
	!minimal? (
		>=x11-proto/xf86driproto-2.1.0
		>=x11-proto/dri2proto-2.3
		>=x11-libs/libdrm-2.3.0
	)"

PDEPEND="
	xorg? ( >=x11-base/xorg-drivers-$(get_version_component_range 1-2) )"

REQUIRED_USE="!minimal? (
		|| ( ${IUSE_SERVERS} )
	)"

# disable-acpi.patch and 1.9-nouveau-default.patch
# are included in the SRPM patch set.
PATCHES=(
	"${FILESDIR}"/xorg-cve-2011-4028+4029.patch
)

pkg_pretend() {
	# older gcc is not supported
	[[ $(gcc-major-version) -lt 4 ]] && \
		die "Sorry, but gcc earlier than 4.0 wont work for xorg-server."
}

pkg_setup() {
	xorg-2_pkg_setup

	# localstatedir is used for the log location; we need to override the default
	#	from ebuild.sh
	# sysconfdir is used for the xorg.conf location; same applies
	#	--enable-install-setuid needed because sparcs default off
	# NOTE: fop is used for doc generating ; and i have no idea if gentoo
	#	package it somewhere
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable ipv6)
		$(use_enable dmx)
		$(use_enable kdrive)
		$(use_enable kdrive kdrive-kbd)
		$(use_enable kdrive kdrive-mouse)
		$(use_enable kdrive kdrive-evdev)
		$(use_enable tslib)
		$(use_enable tslib xcalibrate)
		$(use_enable !minimal record)
		$(use_enable !minimal xfree86-utils)
		$(use_enable !minimal install-libxf86config)
		$(use_enable !minimal dri)
		$(use_enable !minimal dri2)
		$(use_enable !minimal glx)
		$(use_enable xnest)
		$(use_enable xorg)
		$(use_enable xvfb)
		$(use_enable nptl glx-tls)
		$(use_enable udev config-udev)
		$(use_with doc doxygen)
		$(use_with doc xmlto)
		--sysconfdir=/etc/X11
		--localstatedir=/var
		--enable-install-setuid
		--with-fontrootdir=/usr/share/fonts
		--with-xkb-output=/var/lib/xkb
		--disable-config-hal
		--without-dtrace
		--without-fop
		--with-os-vendor=Gentoo
	)

	# Xorg-server requires includes from OS mesa which are not visible for
	# users of binary drivers.
	mkdir -p "${T}/mesa-symlinks/GL"
	for i in gl glx glxmd glxproto glxtokens; do
		ln -s "${EROOT}usr/$(get_libdir)/opengl/xorg-x11/include/$i.h" "${T}/mesa-symlinks/GL/$i.h" || die
	done
	for i in glext glxext; do
		ln -s "${EROOT}usr/$(get_libdir)/opengl/global/include/$i.h" "${T}/mesa-symlinks/GL/$i.h" || die
	done
	append-cppflags "-I${T}/mesa-symlinks"
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch6: xserver-1.7.4-z-now.patch
Patch5002:  xserver-1.4.99-ssh-isnt-local.patch
Patch6011: xserver-1.6.0-less-acpi-brokenness.patch
Patch6016: xserver-1.6.1-nouveau.patch
Patch6027: xserver-1.6.0-displayfd.patch
Patch6030: xserver-1.6.99-right-of.patch
Patch6053: xserver-1.8-disable-vboxvideo.patch
Patch7001: xserver-1.10-pointer-barriers.patch
Patch7002: xserver-1.10-bg-none-revert.patch
Patch7004: xserver-1.1.1-pam.patch
Patch7006: xserver-1.7.6-default-modes.patch
Patch7015: xserver-1.7.7-make-ephyr-resize.patch
Patch7026: xserver-1.7.7-xephyr-24bpp.patch
Patch7027: xserver-1.7.7-int10-reserved-areas.patch
Patch7032: xserver-1.10.1-memcpy-abuse.patch
Patch7033: xserver-1.10.1-dri2-fixes.patch
Patch7100: xserver-1.10.2-xfont-compat.patch
Patch7104: xserver-1.10.2-gdm-compat.patch
Patch7106: xserver-1.10-panning.patch
Patch7107: xserver-1.10.4-dix-don-t-allow-keyboard-devices-to-submit-motion-or.patch
Patch7108: xserver-1.10.4-dix-warn-about-keyboard-events-with-valuator-masks.patch
Patch7109: xserver-1.10.4-dix-NewCurrentScreen-must-work-on-pointers-where-pos.patch
Patch7110: xserver-1.10.4-dix-fill-out-root_x-y-for-keyboard-events.patch
Patch7111: xserver-1.10.4-lid-hack.patch
Patch7112: xserver-1.10.4-xext-don-t-free-uninitialised-pointer-when-malloc-fa.patch
Patch7113: xserver-1.10.4-Xi-avoid-overrun-of-callback-array.patch
Patch7114: xserver-1.10.4-kinput-allocate-enough-space-for-null-character.patch
Patch7115: xserver-1.10.4-xaa-avoid-possible-freed-pointer-reuse-in-epilogue.patch
Patch7116: xserver-1.10.4-xv-test-correct-number-of-requests.patch
Patch7117: xserver-1.10.4-handle-no-modes-harder.patch
Patch7118: xorg-server-1.10.4-kdrive-disable-screen-crossing.patch
Patch8000: xserver-1.10.4-0001-Input-Pass-co-ordinates-by-reference-to-transformAbs.patch
Patch8001: xserver-1.10.4-0002-dix-don-t-pass-x-y-to-transformAbsolute.patch
Patch8002: xserver-1.10.4-0003-dix-drop-x-y-back-into-the-right-valuators-after-tra.patch
Patch8003: xserver-1.10.4-0004-Input-Convert-ValuatorMask-to-double-precision-inter.patch
Patch8004: xserver-1.10.4-0005-Input-Add-double-precision-valuator_mask-API.patch
Patch8005: xserver-1.10.4-0006-Input-Store-clipped-absolute-axes-in-the-mask.patch
Patch8006: xserver-1.10.4-0007-Input-Prepare-moveAbsolute-for-conversion-to-double.patch
Patch8007: xserver-1.10.4-0008-Input-Prepare-moveRelative-for-conversion-to-double.patch
Patch8008: xserver-1.10.4-0009-Input-Convert-clipAxis-moveAbsolute-and-moveRelative.patch
Patch8009: xserver-1.10.4-0010-Input-Convert-transformAbsolute-to-work-on-doubles.patch
Patch8010: xserver-1.10.4-0011-Input-Reset-SD-remainder-when-copying-co-ords-from-M.patch
Patch8011: xserver-1.10.4-0012-input-provide-a-single-function-to-init-DeviceEvents.patch
Patch8012: xserver-1.10.4-0013-dix-update-pointer-acceleration-code-to-use-Valuator.patch
Patch8013: xserver-1.10.4-0014-dix-split-softening-and-constant-deceleration-into-t.patch
Patch8014: xserver-1.10.4-0015-dix-reduce-the-work-done-by-ApplySoftening.patch
Patch8015: xserver-1.10.4-0016-dix-rename-od-d-to-prev_delta-delta.patch
Patch8016: xserver-1.10.4-0017-Input-Convert-acceleration-code-to-using-ValuatorMas.patch
Patch8017: xserver-1.10.4-0018-Input-Remove-x-and-y-from-moveAbsolute-moveRelative.patch
Patch8018: xserver-1.10.4-0019-Input-Convert-rescaleValuatorAxis-to-double.patch
Patch8019: xserver-1.10.4-0020-Input-Don-t-call-positionSprite-for-non-pointer-devi.patch
Patch8020: xserver-1.10.4-0021-Input-Convert-positionSprite-and-GetPointerEvents-to.patch
Patch8021: xserver-1.10.4-0022-Input-Modify-mask-in-place-in-positionSprite.patch
Patch8022: xserver-1.10.4-0023-Input-Make-RawDeviceEvent-use-doubles-internally.patch
Patch8023: xserver-1.10.4-0024-Input-Make-DeviceEvent-use-doubles-internally.patch
Patch8024: xserver-1.10.4-0025-Input-Set-last-valuators-in-GetPointerEvents-only.patch
Patch8025: xserver-1.10.4-0026-Add-include-inpututils.h-to-xkbAccessX.c-for-init_de.patch
Patch8026: xserver-1.10.4-0027-Move-pointOnScreen-to-inpututils.c.patch
Patch8027: xserver-1.10.4-0028-dix-rename-moveAbsolute-to-clipAbsolute.patch
Patch8028: xserver-1.10.4-0029-dix-move-screen-to-device-coordinate-scaling-to-sepa.patch
Patch8029: xserver-1.10.4-0030-dix-drop-screen-argument-from-positionSprite.patch
Patch8030: xserver-1.10.4-0031-mi-return-the-screen-from-miPointerSetPosition.patch
Patch8031: xserver-1.10.4-0032-mi-switch-miPointerSetPosition-to-take-doubles.patch
Patch8032: xserver-1.10.4-0033-dix-move-MD-last.valuator-update-into-fill_pointer_e.patch
Patch8033: xserver-1.10.4-0034-Store-desktop-dimensions-in-screenInfo.patch
Patch8034: xserver-1.10.4-0035-dix-extend-rescaleValuatorAxis-to-take-a-minimum-def.patch
Patch8035: xserver-1.10.4-0036-input-change-pointer-screen-crossing-behaviour-for-m.patch
Patch8036: xserver-1.10.4-0037-dix-if-we-don-t-have-a-sprite-screen-don-t-generate-.patch
Patch8037: xserver-1.10.4-0038-xfree86-expose-Option-TransformationMatrix.patch
Patch8038: xserver-1.10.4-0039-dix-fix-wrong-condition-checking-for-attached-slave-.patch
Patch8039: xserver-1.10.4-dix-when-rescaling-from-master-rescale-from-desktop-.patch"
	lts6_srpm_epatch || die

	xorg-2_src_prepare

	eautoreconf
}

src_install() {
	xorg-2_src_install

	dynamic_libgl_install

	server_based_install

	if ! use minimal &&	use xorg; then
		# Install xorg.conf.example into docs
		dodoc "${AUTOTOOLS_BUILD_DIR}"/hw/xfree86/xorg.conf.example
	fi

	newinitd "${FILESDIR}"/xdm-setup.initd-1 xdm-setup
	newinitd "${FILESDIR}"/xdm.initd-3 xdm
	newconfd "${FILESDIR}"/xdm.confd-3 xdm

	# install the @x11-module-rebuild set for Portage
	insinto /usr/share/portage/config/sets
	newins "${FILESDIR}"/xorg-sets.conf xorg.conf
}

pkg_postinst() {
	# sets up libGL and DRI2 symlinks if needed (ie, on a fresh install)
	eselect opengl set xorg-x11 --use-old

	if [[ ${PV} != 9999 && $(get_version_component_range 2 ${REPLACING_VERSIONS}) != $(get_version_component_range 2 ${PV}) ]]; then
		elog "You should consider reading upgrade guide for this release:"
		elog "	http://www.gentoo.org/proj/en/desktop/x/x11/xorg-server-$(get_version_component_range 1-2)-upgrade-guide.xml"
		echo
		ewarn "You must rebuild all drivers if upgrading from <xorg-server-$(get_version_component_range 1-2)"
		ewarn "because the ABI changed. If you cannot start X because"
		ewarn "of module version mismatch errors, this is your problem."

		echo
		ewarn "You can generate a list of all installed packages in the x11-drivers"
		ewarn "category using this command:"
		ewarn "	emerge portage-utils; qlist -I -C x11-drivers/"
		ewarn "or using sets from portage-2.2:"
		ewarn "	emerge @x11-module-rebuild"
	fi
}

pkg_postrm() {
	# Get rid of module dir to ensure opengl-update works properly
	if [[ -z ${REPLACED_BY_VERSION} && -e ${ROOT}/usr/$(get_libdir)/xorg/modules ]]; then
		rm -rf "${ROOT}"/usr/$(get_libdir)/xorg/modules
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving GL files for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/xorg-x11/extensions
		local x=""
		for x in "${D}"/usr/$(get_libdir)/xorg/modules/extensions/lib{glx,dri,dri2}*; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${D}"/usr/$(get_libdir)/opengl/xorg-x11/extensions
			fi
		done
	eend 0
}

server_based_install() {
	if ! use xorg; then
		rm "${D}"/usr/share/man/man1/Xserver.1x \
			"${D}"/usr/$(get_libdir)/xserver/SecurityPolicy \
			"${D}"/usr/$(get_libdir)/pkgconfig/xorg-server.pc \
			"${D}"/usr/share/man/man1/Xserver.1x
	fi
}
