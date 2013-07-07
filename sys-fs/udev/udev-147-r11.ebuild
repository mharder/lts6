# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev/Attic/udev-147-r1.ebuild,v 1.7 2010/09/27 19:25:35 zzam dead $

EAPI=4

inherit autotools eutils flag-o-matic multilib toolchain-funcs linux-info rpm lts6-rpm

# PATCHSET=${P}-gentoo-patchset-v1

DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html"

SRPM="udev-147-2.46.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 -sh ~sparc ~x86"
IUSE="selinux +devfs-compat -extras introspection"

RESTRICT="test"

COMMON_DEPEND="selinux? ( sys-libs/libselinux )
	extras? (
		sys-apps/acl
		>=sys-apps/usbutils-0.82
		virtual/libusb:0
		sys-apps/pciutils
		dev-libs/glib:2
	)
	introspection? ( dev-libs/gobject-introspection )
	>=sys-apps/util-linux-2.16
	>=sys-libs/glibc-2.7"

DEPEND="${COMMON_DEPEND}
	extras? ( dev-util/gperf )
	>=sys-kernel/linux-headers-2.6.29"

RDEPEND="${COMMON_DEPEND}
	!sys-apps/coldplug
	!<sys-fs/lvm2-2.02.45
	!sys-fs/device-mapper
	>=sys-apps/baselayout-1.12.5"

# required kernel options
CONFIG_CHECK="~INOTIFY_USER ~SIGNALFD ~!SYSFS_DEPRECATED ~!SYSFS_DEPRECATED_V2"

# We need the lib/rcscripts/addon support
# PROVIDE="virtual/dev-manager"

udev_check_KV() {
	local ok=0
	if [[ ${KV_MAJOR} == 2 && ${KV_MINOR} == 6 ]] || [[ ${KV_MAJOR} == 3 ]]
	then
		if kernel_is -ge 2 6 ${KV_PATCH_reliable} ; then
			ok=2
		elif kernel_is -ge 2 6 ${KV_PATCH_min} ; then
			ok=1
		fi
	fi
	return $ok
}

pkg_setup() {
	linux-info_pkg_setup

	udev_libexec_dir="/$(get_libdir)/udev"

	# udev requires signalfd introduced in kernel 2.6.25,
	# but a glibc compiled against >=linux-headers-2.6.27 uses the
	# new signalfd syscall introduced in kernel 2.6.27 without falling back
	# to the old one. So we just depend on 2.6.27 here, see Bug #281312.
	KV_PATCH_min=25
	KV_PATCH_reliable=27
	KV_min=2.6.${KV_PATCH_min}
	KV_reliable=2.6.${KV_PATCH_reliable}

	# always print kernel version requirements
	ewarn
	ewarn "${P} does not support Linux kernel before version ${KV_min}!"
	if [[ ${KV_PATCH_min} != ${KV_PATCH_reliable} ]]; then
		ewarn "For a reliable udev, use at least kernel ${KV_reliable}"
	fi

	echo
	# We don't care about the secondary revision of the kernel.
	# 2.6.30.4 -> 2.6.30 is all we check
	udev_check_KV
	case "$?" in
		2)	einfo "Your kernel version (${KV_FULL}) is new enough to run ${P} reliably." ;;
		1)	ewarn "Your kernel version (${KV_FULL}) is new enough to run ${P},"
			ewarn "but it may be unreliable in some cases."
			ebeep ;;
		0)	eerror "Your kernel version (${KV_FULL}) is too old to run ${P}"
			ebeep ;;
	esac
	echo

	KV_FULL_SRC=${KV_FULL}
	get_running_version
	udev_check_KV
	if [[ "$?" = "0" ]]; then
		eerror
		eerror "udev cannot be restarted after emerging,"
		eerror "as your running kernel version (${KV_FULL}) is too old."
		eerror "You really need to use a newer kernel after a reboot!"
		NO_RESTART=1
		ebeep
	fi
}

sed_libexec_dir() {
	sed -e "s#/lib/udev#${udev_libexec_dir}#" -i "$@"
}

src_prepare() {
	# patches go here...

	SRPM_PATCHLIST="
	Patch1: 0001-cdrom_id-Still-check-profiles-even-if-there-is-no-me.patch
	Patch2: 0002-cdrom_id-remove-deprecated-device-matches.patch
	Patch3: 0003-cdrom_id-open-non-mounted-optical-media-with-O_EXCL.patch
	Patch4: 0004-cdrom_id-remove-debugging-code.patch
	Patch5: 0005-cdrom_id-retry-to-open-the-device-if-EBUSY.patch
	Patch6: 0006-cdrom_id-check-mount-state-in-retry-loop.patch
	Patch7: 0007-cdrom_id-always-set-ID_CDROM-regardless-if-we-can-ru.patch
	Patch8: 0008-replace-add-change-with-remove.patch
	Patch9: 0009-cdrom_id-Fix-uninitialized-variables.patch
	Patch10: 0010-cdrom_id-Fix-uninitialized-buffers.patch

	Patch20: udev-147-cdrom_id-20110209.patch
	Patch21: udev-147-idrac.patch

	Patch101:  udev-141-cpu-online.patch
	Patch102:  udev-147-modem-modeswitch.patch"
	lts6_srpm_epatch || die

	# This patch fails the dry-run, but applies if dry-run is skipped.
	# Patch103:  udev-147-wwn.patch
	einfo "Applying udev-147-wwn.patch..."
	cat "${WORKDIR}/udev-147-wwn.patch" | patch -p1

	SRPM_PATCHLIST="
		Patch104:  udev-147-virtio.patch
		Patch105:  udev-147-layer3.patch
		Patch107:  udev-147-Decrease-buffer-size-when-advancing-past-NUL-byte.patch
		Patch108:  udev-147-Use-UTIL_LINE_SIZE-not-UTIL_PATH_SIZE-to-truncate-pr.patch
		Patch109:  udev-147-Increase-UTIL_LINE_SIZE-from-2048-to-16384.patch
		Patch111:  udev-147-selinux-preserve.patch
		Patch112:  udev-147-xvd_cdrom.patch
		Patch114:  udev-147-virtual.patch
		Patch115:  udev-147-modprobe-hack.patch
		Patch118:  udev-147-no-usb_id-err.patch
		Patch119:  udev-147-virtio-blk-patch_id.patch
		Patch120:  udev-147-changer-symlink.patch
		Patch121:  udev-147-virtio-blk-by-id.patch
		Patch123:  udev-147-rule_gen.patch
		Patch124:  udev-147-rule_gen2.patch
		Patch125:  udev-147-scsi-id-2.patch

		Patch200: udev.git-5539f624.patch
		Patch201: udev.git-c4f6dcc4a5c774c4c5c60c7024d59081deecc7f8.patch
		Patch202: udev.git-484e1b2d11b9b89418589d885a625e647881933b.patch
		Patch203: udev.git-847b4f84c671e98f29f22d8e3e0d70a231d71a7b.patch
		Patch204: udev.git-0c7377880974e6eadac7a3ae9e35d339546dde0d.patch
		Patch205: udev-147-cdrom-virt.patch
		Patch206: udev-147-scsi_id-raw.patch
		Patch207: udev.git-1d67ec16c44711bbfb50ac7dd8bb2fb6e64a80f3.patch
		Patch208: udev.git-d5a01cb8b31bd0791d1617c56d4c669a02018bd7.patch

		Patch210: udev-shproperty.patch

		# keyboard related patches
		Patch300: 0300-README.keymap.txt-small-clarification.patch
		Patch308: 0308-keymap-Add-Acer-Aspire-1810T.patch
		Patch309: 0309-keymap-add-Samsung-N130.patch
		Patch310: 0310-95-keymap.rules-Run-on-change-events-too.patch
		Patch311: 0311-keymap-handle-atkbd-force_release-quirk.patch
		Patch312: 0312-keymap-fix-findkeyboards.patch
		Patch316: 0316-add-Samsung-R70-R71-keymap.patch
		Patch317: 0317-keymap-Add-hotkey-quirk-for-Acer-Aspire-One-AO531h-A.patch
		Patch318: 0318-keymap-Add-Logitech-S510-USB-keyboard.patch
		Patch320: 0320-keymap-add-Acer-TravelMate-8471.patch
		Patch321: 0321-keymap-Add-Acer-Aspire-1810TZ.patch
		Patch322: 0322-keymap-Add-OLPC-XO-key-mappings.patch
		Patch323: 0323-keymap-Fix-typo-in-compal-rules.patch
		Patch324: 0324-keymap-Add-LG-X110.patch
		Patch325: 0325-keymap-Lenovo-Thinkpad-USB-Keyboard-with-Tracepoint.patch
		Patch326: 0326-keymap-Add-Fujitsu-Amilo-Li-1718.patch
		Patch327: 0327-keymap-Document-force-release.patch
		Patch328: 0328-keymap-Samsung-R70-R71-force-release-quirk.patch
		Patch329: 0329-build-keymap-create-subdir.patch
		Patch331: 0331-keymap-support-for-the-Samsung-N140-keyboard.patch
		Patch332: 0332-keymap-move-force-release-directory.patch
		Patch333: 0333-extras-keymap-check-keymaps.sh-Ignore-comment-only-l.patch
		Patch334: 0334-keymap-Fix-invalid-map-line.patch
		Patch335: 0335-keymap-include-linux-limits.h.patch
		Patch336: 0336-keymap-linux-input.h-get-absolute-include-path-from-.patch
		Patch338: 0338-keymap-Add-Dell-Inspiron-1011-Mini-10.patch
		Patch339: 0339-Fix-brightness-keys-on-MSI-Wind-U-100.patch
		Patch340: 0340-keymap-Add-support-for-Gateway-AOA110-AOA150-clones.patch
		Patch341: 0341-keymap-Fix-LG-X110.patch
		Patch342: 0342-Force-key-release-for-volume-keys-on-Dell-Studio-155.patch
		Patch343: 0343-keymap-Add-Toshiba-Satellite-M30X.patch
		Patch345: 0345-keymap-Add-Samsung-Q210-P210-force-release-quirk.patch
		Patch346: 0346-keymap-Add-Fujitsu-Amilo-1848-u-force-release-quirk.patch
		Patch349: 0349-keymap-Add-Acer-TravelMate-6593G-and-Acer-Aspire-164.patch
		Patch350: 0350-keymap-Fix-another-key-for-Acer-TravelMate-6593.patch
		Patch351: 0351-Fix-Keymapping-for-upcoming-Dell-Laptops.patch
		Patch352: 0352-Add-new-Dell-touchpad-keycode.patch
		Patch353: 0353-Revert-special-casing-0xD8-to-latitude-XT-only.patch
		Patch354: 0354-Fix-Dell-Studio-1558-volume-keys-not-releasing.patch
		Patch355: 0355-Add-support-for-another-Dell-touchpad-toggle-key.patch
		Patch357: 0357-keymap-Unite-laptop-models-needing-common-volume-key.patch
		Patch358: 0358-keymap-Add-force-release-quirk-for-Coolbox-QBook-270.patch
		Patch359: 0359-keymap-Add-force-release-quirk-for-Mitac-8050QDA.patch
		Patch361: 0361-Fix-volume-keys-not-releasing-for-Pegatron-platform.patch
		Patch363: 0363-keymap-Fix-Bluetooth-key-on-Acer-TravelMate-4720.patch
		Patch365: 0365-keymap-Add-keymap-and-force-release-quirk-for-Samsun.patch
		Patch366: 0366-keymap-Add-keymap-quirk-of-WebCam-key-for-MSI-netboo.patch
		Patch372: 0372-Fix-wlan-key-on-Inspirion-1210.patch
		Patch375: 0375-Fix-wlan-key-on-Inspiron-910.patch
		Patch376: 0376-Fix-wlan-key-on-Inspiron-1010-1110.patch
		Patch380: 0380-extras-keymap-add-Samsung-N210-to-keymap-rules.patch
		Patch385: 0385-Fix-stuck-volume-key-presses-for-Toshiba-Satellite-U.patch
		Patch387: 0387-keymap-Add-support-for-IBM-branded-USB-devices.patch
		Patch388: 0388-keymap-Add-Logitech-Cordless-Wave-Pro.patch
		Patch389: 0389-keymap-Find-alternate-Lenovo-module.patch
		Patch390: 0390-keymap-Add-Lenovo-ThinkPad-SL-Series-extra-buttons.patch
		Patch391: 0391-Fix-volume-keys-not-releasing-on-Mivvy-G310.patch
		Patch393: 0393-keymap-Generalize-Samsung-keymaps.patch
		Patch394: 0394-keymap-Add-force-release-quirks-for-a-lot-more-Samsu.patch
		Patch396: 0396-Add-keymap-for-Lenovo-IdeaPad-S10-3.patch
		Patch397: 0397-keymap-Add-Onkyo-PC.patch
		Patch398: 0398-keymap-Add-HP-G60.patch
		Patch399: 0399-keymap-Fix-Sony-VAIO-VGN-SZ2HP-B.patch
		Patch400: 0400-keymap-Fix-Acer-TravelMate-4720.patch
		Patch402: 0402-keymap-Add-Lenovo-Y550.patch
		Patch404: 0404-keymap-Add-alternate-MSI-vendor-name.patch
		Patch409: 0409-keymap-Apply-force-release-rules-to-all-Samsung-mode.patch
		Patch410: 0410-keymap-Add-Toshiba-Satellite-U500.patch
		Patch412: 0412-keymap-Add-Sony-Vaio-VGN71.patch
		Patch413: 0413-keymap-Add-some-more-Sony-Vaio-VGN-models.patch
		Patch414: 0414-keymap-Add-force-release-for-HP-touchpad-off.patch
		Patch415: 0415-extras-keymap-Make-touchpad-buttons-consistent.patch
		Patch416: 0416-keymap-Add-release-quirks-for-two-Zepto-Znote-models.patch
		Patch417: 0417-keymap-Fix-struck-Touchpad-key-on-Dell-Latitude-E-se.patch
		Patch418: 0418-keymap-Fix-struck-Touchpad-key-on-Dell-Precision-M-s.patch

		Patch500: udev.git-5c3ebbf35a2c101e0212c7066f0d65e457fcf40c.patch
		Patch501: udev.git-c54b43e2c233e724f840c4f6a0a81bdd549e40bb.patch
		Patch502: udev-147-modeswitch.patch
		Patch504: udev-147-iosched.patch
		Patch505: udev.git-e48e2912023b5600d291904b0f7b0017387e8cb2.patch
		Patch506: udev.git-135f3e8d0b4b4968908421b677c9ef2ba860b71d.patch
		Patch507: udev.git-00f34bc435f51decab266f2e9a7be223df15c87e.patch
		Patch508: udev.git-851dd4ddc5aeb1ee517145d9e3334c2017595321.patch

		Patch600: add-xvd-detection-to-storage-rules.patch
		Patch601: udev-kname.patch
		Patch602: udev-nowatch-man.patch
		Patch603: udev-147-path_id-cciss.patch
		Patch604: udev-147-docenc.patch
		Patch605: udev-147-cdrom_id-profiles.patch
		Patch606: udev-147-rename-symlink-info.patch

		Patch700: udev-nousbutils.patch

		# TODO: remove patch, when binutils is fixed
		# https://bugzilla.redhat.com/show_bug.cgi?id=825736
		Patch9999: udev-dummy.patch
"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/udev-164-remove-v4l1.patch

	if ! use devfs-compat; then
		# see Bug #269359
		epatch "${FILESDIR}"/udev-141-remove-devfs-names.diff
	fi

	# change rules back to group uucp instead of dialout for now
	sed -e 's/GROUP="dialout"/GROUP="uucp"/' \
		-i rules/{rules.d,packages,gentoo}/*.rules \
	|| die "failed to change group dialout to uucp"

	sed_libexec_dir \
		rules/rules.d/50-udev-default.rules \
		rules/rules.d/78-sound-card.rules \
		extras/rule_generator/write_*_rules \
		|| die "sed failed"

	eautoreconf
}

src_configure() {
	filter-flags -fprefetch-loop-arrays

	econf \
		--prefix=/usr \
		--sysconfdir=/etc \
		--sbindir=/sbin \
		--libdir=/usr/$(get_libdir) \
		--with-rootlibdir=/$(get_libdir) \
		--libexecdir="${udev_libexec_dir}" \
		--enable-logging \
		$(use_with selinux) \
		$(use_enable extras) \
		$(use_enable introspection)
}

src_install() {
	local scriptdir="${FILESDIR}/147"

	into /
	emake DESTDIR="${D}" install || die "make install failed"
	# without this code, multilib-strict is angry
	if [[ "$(get_libdir)" != "lib" ]]; then
		# check if this code is needed, bug #281338
		if [[ -d "${D}/lib" ]]; then
			# we can not just rename /lib to /lib64, because
			# make install creates /lib64 and /lib
			einfo "Moving lib to $(get_libdir)"
			mkdir -p "${D}/$(get_libdir)"
			mv "${D}"/lib/* "${D}/$(get_libdir)/"
			rmdir "${D}"/lib
		else
			einfo "There is no ${D}/lib, move code can be deleted."
		fi
	fi

	exeinto "${udev_libexec_dir}"
	newexe "${FILESDIR}"/net-130-r1.sh net.sh	|| die "net.sh not installed properly"
	newexe "${FILESDIR}"/move_tmp_persistent_rules-112-r1.sh move_tmp_persistent_rules.sh \
		|| die "move_tmp_persistent_rules.sh not installed properly"
	newexe "${FILESDIR}"/write_root_link_rule-125 write_root_link_rule \
		|| die "write_root_link_rule not installed properly"

	doexe "${scriptdir}"/shell-compat-KV.sh \
		|| die "shell-compat.sh not installed properly"
	doexe "${scriptdir}"/shell-compat-addon.sh \
		|| die "shell-compat.sh not installed properly"

	keepdir "${udev_libexec_dir}"/state
	keepdir "${udev_libexec_dir}"/devices

	# create symlinks for these utilities to /sbin
	# where multipath-tools expect them to be (Bug #168588)
	dosym "..${udev_libexec_dir}/scsi_id" /sbin/scsi_id

	# Add gentoo stuff to udev.conf
	echo "# If you need to change mount-options, do it in /etc/fstab" \
	>> "${D}"/etc/udev/udev.conf

	# let the dir exist at least
	keepdir /etc/udev/rules.d

	# Now installing rules
	cd "${S}"/rules
	insinto "${udev_libexec_dir}"/rules.d/

	# Our rules files
	doins gentoo/??-*.rules
	doins packages/40-isdn.rules

	# Adding arch specific rules
	if [[ -f packages/40-${ARCH}.rules ]]
	then
		doins "packages/40-${ARCH}.rules"
	fi
	cd "${S}"

	# our udev hooks into the rc system
	insinto /$(get_libdir)/rcscripts/addons
	doins "${scriptdir}"/udev-start.sh \
		|| die "udev-start.sh not installed properly"
	doins "${scriptdir}"/udev-stop.sh \
		|| die "udev-stop.sh not installed properly"

	local init
	# udev-postmount and init-scripts for >=openrc-0.3.1, Bug #240984
	for init in udev udev-mount udev-dev-tarball udev-postmount; do
		newinitd "${scriptdir}/${init}.initd" "${init}" \
			|| die "initscript ${init} not installed properly"
	done

	# insert minimum kernel versions
	sed -e "s/%KV_MIN%/${KV_min}/" \
		-e "s/%KV_MIN_RELIABLE%/${KV_reliable}/" \
		-i "${D}"/etc/init.d/udev-mount

	# config file for init-script and start-addon
	newconfd "${scriptdir}/udev.confd" udev \
		|| die "config file not installed properly"

	insinto /etc/modprobe.d
	newins "${FILESDIR}"/blacklist-146 blacklist.conf
	newins "${FILESDIR}"/pnp-aliases pnp-aliases.conf

	# convert /lib/udev to real used dir
	sed_libexec_dir \
		"${D}/$(get_libdir)"/rcscripts/addons/*.sh \
		"${D}/${udev_libexec_dir}"/write_root_link_rule \
		"${D}"/etc/conf.d/udev \
		"${D}"/etc/init.d/udev* \
		"${D}"/etc/modprobe.d/*

	# documentation
	dodoc ChangeLog README TODO || die "failed installing docs"

	# keep doc in just one directory, Bug #281137
	rm -rf "${D}/usr/share/doc/${PN}"
	if use extras; then
		dodoc extras/keymap/README.keymap.txt || die "failed installing docs"
	fi

	cd docs/writing_udev_rules
	mv index.html writing_udev_rules.html
	dohtml *.html
	cd "${S}"

	echo "CONFIG_PROTECT_MASK=\"/etc/udev/rules.d\"" > 20udev
	doenvd 20udev
}

pkg_preinst() {
	# moving old files to support newer modprobe, 12 May 2009
	local f dir=${ROOT}/etc/modprobe.d/
	for f in pnp-aliases blacklist; do
		if [[ -f $dir/$f && ! -f $dir/$f.conf ]]
		then
			elog "Moving $dir/$f to $f.conf"
			mv -f "$dir/$f" "$dir/$f.conf"
		fi
	done

	if [[ -d ${ROOT}/lib/udev-state ]]
	then
		mv -f "${ROOT}"/lib/udev-state/* "${D}"/lib/udev/state/
		rm -r "${ROOT}"/lib/udev-state
	fi

	if [[ -f ${ROOT}/etc/udev/udev.config &&
	     ! -f ${ROOT}/etc/udev/udev.rules ]]
	then
		mv -f "${ROOT}"/etc/udev/udev.config "${ROOT}"/etc/udev/udev.rules
	fi

	# delete the old udev.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/udev.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/udev.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/05-wait_for_sysfs.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/05-wait_for_sysfs.hotplug
	fi

	# delete the old wait_for_sysfs.hotplug symlink if it is present
	if [[ -h ${ROOT}/etc/hotplug.d/default/10-udev.hotplug ]]
	then
		rm -f "${ROOT}"/etc/hotplug.d/default/10-udev.hotplug
	fi

	has_version "=${CATEGORY}/${PN}-103-r3"
	previous_equal_to_103_r3=$?

	has_version "<${CATEGORY}/${PN}-104-r5"
	previous_less_than_104_r5=$?

	has_version "<${CATEGORY}/${PN}-106-r5"
	previous_less_than_106_r5=$?

	has_version "<${CATEGORY}/${PN}-113"
	previous_less_than_113=$?
}

# 19 Nov 2008
fix_old_persistent_net_rules() {
	local rules=${ROOT}/etc/udev/rules.d/70-persistent-net.rules
	[[ -f ${rules} ]] || return

	elog
	elog "Updating persistent-net rules file"

	# Change ATTRS to ATTR matches, Bug #246927
	sed -i -e 's/ATTRS{/ATTR{/g' "${rules}"

	# Add KERNEL matches if missing, Bug #246849
	sed -ri \
		-e '/KERNEL/ ! { s/NAME="(eth|wlan|ath)([0-9]+)"/KERNEL=="\1*", NAME="\1\2"/}' \
		"${rules}"
}

# See Bug #129204 for a discussion about restarting udevd
restart_udevd() {
	if [[ ${NO_RESTART} = "1" ]]; then
		ewarn "Not restarting udevd, as your kernel is too old!"
		return
	fi

	# need to merge to our system
	[[ ${ROOT} = / ]] || return

	# check if root of init-process is identical to ours (not in chroot)
	[[ -r /proc/1/root && /proc/1/root/ -ef /proc/self/root/ ]] || return

	# abort if there is no udevd running
	[[ -n $(pidof udevd) ]] || return

	# abort if no /dev/.udev exists
	[[ -e /dev/.udev ]] || return

	elog
	elog "restarting udevd now."

	killall -15 udevd &>/dev/null
	sleep 1
	killall -9 udevd &>/dev/null

	/sbin/udevd --daemon
	sleep 3
	if [[ ! -n $(pidof udevd) ]]; then
		eerror "FATAL: udev died, please check your kernel is"
		eerror "new enough and configured correctly for ${P}."
		eerror
		eerror "Please have a look at this before rebooting."
		eerror "If in doubt, please downgrade udev back to your old version"
		ebeep
	fi
}

postinst_init_scripts() {
	# FIXME: we may need some code that detects if this is a system bootstrap
	# and auto-enables udev then
	#
	# FIXME: inconsistent handling of init-scripts here
	#  * udev is added to sysinit in openrc-ebuild
	#  * we add udev-postmount to default in here
	#

	# migration to >=openrc-0.4
	if [[ -e "${ROOT}"/etc/runlevels/sysinit && ! -e "${ROOT}"/etc/runlevels/sysinit/udev ]]
	then
		ewarn
		ewarn "You need to add the udev init script to the runlevel sysinit,"
		ewarn "else your system will not be able to boot"
		ewarn "after updating to >=openrc-0.4.0"
		ewarn "Run this to enable udev for >=openrc-0.4.0:"
		ewarn "\trc-update add udev sysinit"
		ewarn
	fi

	# add udev-postmount to default runlevel instead of that ugly injecting
	# like a hotplug event, 2009/10/15

	# already enabled?
	[[ -e "${ROOT}"/etc/runlevels/default/udev-postmount ]] && return

	local enable_postmount=0
	[[ -e "${ROOT}"/etc/runlevels/sysinit/udev ]] && enable_postmount=1
	[[ "${ROOT}" = "/" && -d /dev/.udev/ ]] && enable_postmount=1

	if [[ ${enable_postmount} = 1 ]]
	then
		local initd=udev-postmount

		if [[ -e ${ROOT}/etc/init.d/${initd} ]] && \
			[[ ! -e ${ROOT}/etc/runlevels/default/${initd} ]]
		then
			ln -snf /etc/init.d/${initd} "${ROOT}"/etc/runlevels/default/${initd}
			elog "Auto-adding '${initd}' service to your default runlevel"
		fi
	else
		elog "You should add the udev-postmount service to default runlevel."
		elog "Run this to add it:"
		elog "\trc-update add udev-postmount default"
	fi
}

pkg_postinst() {
	fix_old_persistent_net_rules

	restart_udevd

	postinst_init_scripts

	# people want reminders, I'll give them reminders.  Odds are they will
	# just ignore them anyway...

	# delete 40-scsi-hotplug.rules, it is integrated in 50-udev.rules, 19 Jan 2007
	if [[ $previous_equal_to_103_r3 = 0 ]] &&
		[[ -e ${ROOT}/etc/udev/rules.d/40-scsi-hotplug.rules ]]
	then
		ewarn "Deleting stray 40-scsi-hotplug.rules"
		ewarn "installed by sys-fs/udev-103-r3"
		rm -f "${ROOT}"/etc/udev/rules.d/40-scsi-hotplug.rules
	fi

	# Removing some device-nodes we thought we need some time ago, 25 Jan 2007
	if [[ -d ${ROOT}/lib/udev/devices ]]
	then
		rm -f "${ROOT}"/lib/udev/devices/{null,zero,console,urandom}
	fi

	# Removing some old file, 29 Jan 2007
	if [[ $previous_less_than_104_r5 = 0 ]]
	then
		rm -f "${ROOT}"/etc/dev.d/net/hotplug.dev
		rmdir --ignore-fail-on-non-empty "${ROOT}"/etc/dev.d/net 2>/dev/null
	fi

	# 19 Mar 2007
	if [[ $previous_less_than_106_r5 = 0 ]] &&
		[[ -e ${ROOT}/etc/udev/rules.d/95-net.rules ]]
	then
		rm -f "${ROOT}"/etc/udev/rules.d/95-net.rules
	fi

	# Try to remove /etc/dev.d as that is obsolete, 23 Apr 2007
	if [[ -d ${ROOT}/etc/dev.d ]]
	then
		rmdir --ignore-fail-on-non-empty "${ROOT}"/etc/dev.d/default "${ROOT}"/etc/dev.d 2>/dev/null
		if [[ -d ${ROOT}/etc/dev.d ]]
		then
			ewarn "You still have the directory /etc/dev.d on your system."
			ewarn "This is no longer used by udev and can be removed."
		fi
	fi

	# 64-device-mapper.rules now gets installed by sys-fs/device-mapper
	# remove it if user don't has sys-fs/device-mapper installed, 27 Jun 2007
	if [[ $previous_less_than_113 = 0 ]] &&
		[[ -f ${ROOT}/etc/udev/rules.d/64-device-mapper.rules ]] &&
		! has_version sys-fs/device-mapper
	then
			rm -f "${ROOT}"/etc/udev/rules.d/64-device-mapper.rules
			einfo "Removed unneeded file 64-device-mapper.rules"
	fi

	# requested in bug #275974, added 2009/09/05
	ewarn
	ewarn "If after the udev update removable devices or CD/DVD drives"
	ewarn "stop working, try re-emerging HAL before filling a bug report"

	# requested in Bug #225033:
	elog
	elog "persistent-net does assigning fixed names to network devices."
	elog "If you have problems with the persistent-net rules,"
	elog "just delete the rules file"
	elog "\trm ${ROOT}etc/udev/rules.d/70-persistent-net.rules"
	elog "and then reboot."
	elog
	elog "This may however number your devices in a different way than they are now."

	ewarn
	ewarn "If you build an initramfs including udev, then please"
	ewarn "make sure that the /sbin/udevadm binary gets included,"
	ewarn "and your scripts changed to use it,as it replaces the"
	ewarn "old helper apps udevinfo, udevtrigger, ..."

	ewarn
	ewarn "mount options for directory /dev are no longer"
	ewarn "set in /etc/udev/udev.conf, but in /etc/fstab"
	ewarn "as for other directories."

	if use devfs-compat; then
		ewarn
		ewarn "devfs-compat use flag is enabled (by default)."
		ewarn "This enables devfs compatible device names."
		ewarn "If you use /dev/md/*, /dev/loop/* or /dev/rd/*,"
		ewarn "then please migrate over to using the device names"
		ewarn "/dev/md*, /dev/loop* and /dev/ram*."
		ewarn "The devfs-compat rules will be removed in the future."
		ewarn "For reference see Bug #269359."
	fi

	elog
	elog "For more information on udev on Gentoo, writing udev rules, and"
	elog "         fixing known issues visit:"
	elog "         http://www.gentoo.org/doc/en/udev-guide.xml"
}
