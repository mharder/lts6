# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-base/xorg-server/xorg-server-1.10.6-r1.ebuild,v 1.8 2012/06/21 16:04:50 jer Exp $

EAPI=4

XORG_DOC=doc
inherit xorg-2 multilib versionator rpm lts6-rpm

DESCRIPTION="X.Org X servers"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"

SRPM="xorg-x11-server-1.10.6-1.sl6.src.rpm"
SRC_URI="mirror://lts63/sl6-changed/${SRPM}"
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
	>=x11-libs/libpciaccess-0.10.6
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
	>=x11-proto/videoproto-2.2.2
	>=x11-proto/xcmiscproto-1.2.0
	>=x11-proto/xextproto-7.1.99
	>=x11-proto/xf86dgaproto-2.0.99.1
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
		>=x11-libs/libdrm-2.4.0
	)"

PDEPEND="
	xorg? ( >=x11-base/xorg-drivers-$(get_version_component_range 1-2) )"

REQUIRED_USE="!minimal? (
		|| ( ${IUSE_SERVERS} )
	)"

# disable-acpi.patch and 1.9-nouveau-default.patch
# are included in the SRPM patch set.
PATCHES=(
	"${UPSTREAMED_PATCHES[@]}"
	"${FILESDIR}"/${PN}-1.11-log-format-fix.patch
)

SRPM_PATCHLIST="
Patch0001: 0001-link-with-z-now.patch
Patch0002: 0002-Hack-for-proper-MIT-SHM-rejection-for-ssh-forwarded-.patch
Patch0003: 0003-Don-t-build-the-ACPI-code.patch
Patch0004: 0004-autoconfig-select-nouveau-by-default-for-NVIDIA-GPUs.patch
Patch0005: 0005-displayfd-hack.patch
Patch0006: 0006-RANDR-right-of-placement-by-default.patch
Patch0007: 0007-disable-vboxvideo-driver-in-autodetect-code.patch
Patch0008: 0008-CRTC-confine-and-pointer-barriers.patch
Patch0009: 0009-Revert-composite-Don-t-backfill-non-bg-None-windows.patch
Patch0010: 0010-Enable-PAM-support.patch
Patch0011: 0011-modes-Combine-xf86DefaultModes-and-DMTModes.patch
Patch0012: 0012-make-ephyr-resizeable-600505.patch
Patch0013: 0013-kdrive-ephyr-Fix-crash-on-24bpp-host-framebuffer.patch
Patch0014: 0014-int10-Map-up-to-one-e820-reserved-area-if-it-looks-l.patch
Patch0015: 0015-dri2-Invalidate-DRI2-buffers-for-all-windows-with-th.patch
Patch0016: 0016-Revert-dix-use-one-single-function-to-register-fpe-f.patch
Patch0017: 0017-Re-add-nr-command-line-option-for-gdm-compatibility.patch
Patch0018: 0018-xf86RandR12-Don-t-call-ConstrainCursorHarder-if-pann.patch
Patch0019: 0019-dix-don-t-allow-keyboard-devices-to-submit-motion-or.patch
Patch0020: 0020-dix-warn-about-keyboard-events-with-valuator-masks.patch
Patch0021: 0021-dix-NewCurrentScreen-must-work-on-pointers-where-pos.patch
Patch0022: 0022-dix-fill-out-root_x-y-for-keyboard-events.patch
Patch0023: 0023-xfree86-Lid-status-hack.patch
Patch0024: 0024-kinput-allocate-enough-space-for-null-character.patch
Patch0025: 0025-xaa-Disable-Composite-in-24bpp-due-to-cw-651934.patch
Patch0026: 0026-Input-Pass-co-ordinates-by-reference-to-transformAbs.patch
Patch0027: 0027-dix-don-t-pass-x-y-to-transformAbsolute.patch
Patch0028: 0028-dix-drop-x-y-back-into-the-right-valuators-after-tra.patch
Patch0029: 0029-Input-Convert-ValuatorMask-to-double-precision-inter.patch
Patch0030: 0030-Input-Add-double-precision-valuator_mask-API.patch
Patch0031: 0031-Input-Store-clipped-absolute-axes-in-the-mask.patch
Patch0032: 0032-Input-Prepare-moveAbsolute-for-conversion-to-double.patch
Patch0033: 0033-Input-Prepare-moveRelative-for-conversion-to-double.patch
Patch0034: 0034-Input-Convert-clipAxis-moveAbsolute-and-moveRelative.patch
Patch0035: 0035-Input-Convert-transformAbsolute-to-work-on-doubles.patch
Patch0036: 0036-Input-Reset-SD-remainder-when-copying-co-ords-from-M.patch
Patch0037: 0037-input-provide-a-single-function-to-init-DeviceEvents.patch
Patch0038: 0038-dix-update-pointer-acceleration-code-to-use-Valuator.patch
Patch0039: 0039-dix-split-softening-and-constant-deceleration-into-t.patch
Patch0040: 0040-dix-reduce-the-work-done-by-ApplySoftening.patch
Patch0041: 0041-dix-rename-od-d-to-prev_delta-delta.patch
Patch0042: 0042-Input-Convert-acceleration-code-to-using-ValuatorMas.patch
Patch0043: 0043-Input-Remove-x-and-y-from-moveAbsolute-moveRelative.patch
Patch0044: 0044-Input-Convert-rescaleValuatorAxis-to-double.patch
Patch0045: 0045-Input-Don-t-call-positionSprite-for-non-pointer-devi.patch
Patch0046: 0046-Input-Convert-positionSprite-and-GetPointerEvents-to.patch
Patch0047: 0047-Input-Modify-mask-in-place-in-positionSprite.patch
Patch0048: 0048-Input-Make-RawDeviceEvent-use-doubles-internally.patch
Patch0049: 0049-Input-Make-DeviceEvent-use-doubles-internally.patch
Patch0050: 0050-Input-Set-last-valuators-in-GetPointerEvents-only.patch
Patch0051: 0051-Add-include-inpututils.h-to-xkbAccessX.c-for-init_de.patch
Patch0052: 0052-Move-pointOnScreen-to-inpututils.c.patch
Patch0053: 0053-dix-rename-moveAbsolute-to-clipAbsolute.patch
Patch0054: 0054-dix-move-screen-to-device-coordinate-scaling-to-sepa.patch
Patch0055: 0055-dix-drop-screen-argument-from-positionSprite.patch
Patch0056: 0056-mi-return-the-screen-from-miPointerSetPosition.patch
Patch0057: 0057-mi-switch-miPointerSetPosition-to-take-doubles.patch
Patch0058: 0058-dix-move-MD-last.valuator-update-into-fill_pointer_e.patch
Patch0059: 0059-Store-desktop-dimensions-in-screenInfo.patch
Patch0060: 0060-dix-extend-rescaleValuatorAxis-to-take-a-minimum-def.patch
Patch0061: 0061-input-change-pointer-screen-crossing-behaviour-for-m.patch
Patch0062: 0062-dix-if-we-don-t-have-a-sprite-screen-don-t-generate-.patch
Patch0063: 0063-xfree86-expose-Option-TransformationMatrix.patch
Patch0064: 0064-dix-fix-wrong-condition-checking-for-attached-slave-.patch
Patch0065: 0065-dix-when-rescaling-from-master-rescale-from-desktop-.patch
Patch0066: 0066-randr-Fix-up-another-corner-case-in-preferred-mode-s.patch
Patch0067: 0067-vbe-Only-interpret-complete-failure-as-DDC-unsupport.patch
Patch0068: 0068-Revert-Xext-Fix-edge-case-with-Positive-Negative-Tra.patch
Patch0069: 0069-dix-set-raw-event-values-before-adding-up-relative-v.patch
"

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

src_prepare() {
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
	newinitd "${FILESDIR}"/xdm.initd-5 xdm
	newconfd "${FILESDIR}"/xdm.confd-4 xdm

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
