# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/util-linux/Attic/util-linux-2.17.2.ebuild,v 1.12 2011/12/30 19:30:43 ulm Exp $

EAPI="4"

inherit autotools eutils toolchain-funcs libtool flag-o-matic rpm lts6-rpm

MY_PV=${PV/_/-}
MY_P=${PN}-ng-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux/"

SRPM="util-linux-ng-2.17.2-12.4.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	loop-aes? ( http://loop-aes.sourceforge.net/updates/util-linux-ng-2.17.1-20100308.diff.bz2 )"
RESTRICT="mirror"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"

LICENSE="GPL-2 GPL-3 LGPL-2.1 BSD-4 MIT public-domain"
SLOT="0"
IUSE="crypt loop-aes nls old-linux perl selinux slang uclibc unicode"

RDEPEND="!sys-process/schedutils
	!sys-apps/setarch
	>=sys-libs/ncurses-5.2-r2
	!<sys-libs/e2fsprogs-libs-1.41.8
	!<sys-fs/e2fsprogs-1.41.8
	perl? ( dev-lang/perl )
	selinux? ( sys-libs/libselinux )
	slang? ( sys-libs/slang )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	virtual/os-headers"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./floppy-0.16.tar.bz2" || die
	unpack "./${PN}-ng-${PV}.tar.bz2" || die
	mv "${WORKDIR}/floppy-0.16" "${S}" || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: util-linux-ng-2.13-floppy-locale.patch
Patch1: util-linux-ng-2.13-fdformat-man-ide.patch
Patch2: util-linux-ng-2.13-floppy-generic.patch
Patch4: util-linux-ng-2.13-ctrlaltdel-man.patch
Patch5: util-linux-ng-2.16-blkid-cachefile.patch
Patch7: util-linux-ng-2.13-login-lastlog.patch
Patch8: util-linux-ng-2.15-ipcs-32bit.patch
Patch9: util-linux-ng-2.17-blkid-removable.patch
Patch10: util-linux-ng-2.17-blkid-usec.patch
Patch11: util-linux-ng-2.17-blkid-cdrom.patch
Patch12: util-linux-ng-2.17-blkid-raid.patch
Patch13: util-linux-ng-2.17-script-utempter.patch
Patch14: util-linux-ng-2.17-fdisk-move.patch
Patch15: util-linux-ng-2.17-partx.patch
Patch16: util-linux-ng-2.17-blkid-i.patch
Patch17: util-linux-ng-2.17-wipefs-leak.patch
Patch18: util-linux-ng-2.17-blkid-zfs.patch
Patch19: util-linux-ng-2.17-fdisk-dm.patch
Patch20: util-linux-ng-2.17-lscpu-rebase.patch
Patch21: util-linux-ng-2.17-fsfreeze.patch
Patch22: util-linux-ng-2.17-agetty-clocal.patch
Patch23: util-linux-ng-2.17-rnetdev.patch
Patch24: util-linux-ng-2.17-fsck-rc.patch
Patch25: util-linux-ng-2.17-losetup-rc.patch
Patch26: util-linux-ng-2.17-mount-man-cifs.patch
Patch27: util-linux-ng-2.17-mkfs-man.patch
Patch28: util-linux-ng-2.17-column-segfaul.patch
Patch29: util-linux-ng-2.17-fdisk-512.patch
Patch30: util-linux-ng-2.17-fdisk-canonicalize.patch
Patch31: util-linux-ng-2.17-blkid-sbmagic.patch
Patch32: util-linux-ng-2.17-blkid-filter.patch
Patch33: util-linux-ng-2.17-mount-selinux-remount.patch
Patch34: util-linux-ng-2.17-fsck-parallel.patch
Patch35: util-linux-ng-2.17-lsblk.patch
Patch36: util-linux-ng-2.17-mount-subtype.patch
Patch37: util-linux-ng-2.17-mount-autoclear.patch
Patch38: util-linux-ng-2.17-findmnt.patch
Patch39: util-linux-ng-2.17-mount-man-atime.patch
Patch40: util-linux-ng-2.17-mount-man-ext.patch
Patch41: util-linux-ng-2.17-umount-fake.patch
Patch42: util-linux-ng-2.17-libuuid-rebase.patch
Patch43: util-linux-ng-2.17-fsck-getopt.patch
Patch44: util-linux-ng-2.17-login-setgid.patch
Patch45: util-linux-ng-2.17-readlink.patch
Patch46: util-linux-ng-2.17-wholedisk.patch
Patch47: util-linux-ng-2.17-coverity-e62.patch
Patch48: util-linux-ng-2.17-cfdisk-size.patch
Patch49: util-linux-ng-2.17-ipcs-uid.patch
Patch50: util-linux-ng-2.17-wipefs-pt.patch
Patch51: util-linux-ng-2.17-fstab-man-blank.patch
Patch52: util-linux-ng-2.17-mount-fstab-broken.patch
Patch53: util-linux-ng-2.17-tailf-man-lines.patch
Patch54: util-linux-ng-2.17-swapon-dm.patch
Patch55: util-linux-ng-2.17-fstrim.patch
Patch56: util-linux-ng-2.17-blkid-128-devices.patch
Patch57: util-linux-ng-2.17-login-hush.patch
Patch58: util-linux-ng-2.17-agetty-remote.patch
Patch59: util-linux-ng-2.17-mount-mtab.patch
Patch60: util-linux-ng-2.17-umount-mtab.patch"

	lts6_srpm_epatch || die

	use loop-aes && epatch "${WORKDIR}"/util-linux-ng-*.diff

	use uclibc && sed -i -e s/versionsort/alphasort/g -e s/strverscmp.h/dirent.h/g mount/lomount.c
	eautoreconf
}

lfs_fallocate_test() {
	# Make sure we can use fallocate with LFS #300307
	cat <<-EOF > "${T}"/fallocate.c
	#define _GNU_SOURCE
	#include <fcntl.h>
	main() { return fallocate(0, 0, 0, 0); }
	EOF
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} "${T}"/fallocate.c -o /dev/null >/dev/null 2>&1 \
		|| export ac_cv_func_fallocate=no
	rm -f "${T}"/fallocate.c
}

src_configure() {
	lfs_fallocate_test
	econf \
		$(use_enable nls) \
		--enable-agetty \
		--enable-cramfs \
		$(use_enable old-linux elvtune) \
		--disable-init \
		--disable-kill \
		--disable-last \
		--disable-mesg \
		--enable-partx \
		--enable-raw \
		--enable-rdev \
		--enable-rename \
		--disable-reset \
		--disable-login-utils \
		--enable-schedutils \
		--disable-wall \
		--enable-write \
		--without-pam \
		$(use unicode || echo --with-ncurses) \
		$(use_with selinux) \
		$(use_with slang) \
		$(tc-has-tls || echo --disable-tls)

	cd "${S}/floppy-0.16"
	econf --disable-gtk2
}

src_compile() {
	emake

	cd "${S}/floppy-0.16"
	emake
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	dodoc AUTHORS NEWS README* TODO docs/*

	if ! use perl ; then #284093
		rm "${ED}"/usr/bin/chkdupexe || die
		rm "${ED}"/usr/share/man/man1/chkdupexe.1 || die
	fi

	# need the libs in /
	gen_usr_ldscript -a blkid uuid
	# e2fsprogs-libs didnt install .la files, and .pc work fine
	rm -f "${ED}"/usr/$(get_libdir)/*.la

	if use crypt ; then
		newinitd "${FILESDIR}"/crypto-loop.initd crypto-loop || die
		newconfd "${FILESDIR}"/crypto-loop.confd crypto-loop || die
	fi

	cd "${S}/floppy-0.16"
	emake install DESTDIR="${D}" || die "floppy-0.16 install failed"
}
