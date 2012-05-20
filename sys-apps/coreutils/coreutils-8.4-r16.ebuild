# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/coreutils/Attic/coreutils-8.4.ebuild,v 1.12 2010/05/24 12:26:09 nixnut Exp $

EAPI="4"

inherit autotools eutils flag-o-matic toolchain-funcs rpm lts6-rpm

DESCRIPTION="Standard GNU file utilities (chmod, cp, dd, dir, ls...), text utilities (sort, tr, head, wc..), and shell utilities (whoami, who,...)"
HOMEPAGE="http://www.gnu.org/software/coreutils/"
SRPM="coreutils-8.4-16.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="acl caps gmp nls selinux static unicode xattr"

RDEPEND="caps? ( sys-libs/libcap )
	gmp? ( dev-libs/gmp )
	selinux? ( sys-libs/libselinux )
	acl? ( sys-apps/acl )
	xattr? ( sys-apps/attr )
	nls? ( >=sys-devel/gettext-0.15 )
	!<sys-apps/util-linux-2.13
	!sys-apps/stat
	!net-mail/base64
	!sys-apps/mktemp
	!<app-forensics/tct-1.18-r1
	!<net-fs/netatalk-2.0.3-r4
	!<sci-chemistry/ccp4-6.1.1
	>=sys-libs/ncurses-5.3-r5"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_unpack() {
	rpm_src_unpack || die

	# The rpm eclass doesn't support .xz archives yet.
	unpack "./${P}.tar.xz" || die
}

src_prepare() {
	cd "${S}"

	SRPM_PATCHLIST="Patch100: coreutils-6.10-configuration.patch
			Patch101: coreutils-6.10-manpages.patch
			Patch102: coreutils-7.4-sttytcsadrain.patch
			Patch103: coreutils-445213-stty-dtrdsr.patch
			Patch104: coreutils-8.2-uname-processortype.patch
			Patch105: coreutils-df-direct.patch
			Patch106: coreutils-fuzzyjapanesetranslation.patch
			Patch703: sh-utils-2.0.11-dateman.patch
			Patch704: sh-utils-1.16-paths.patch
			Patch706: coreutils-pam.patch
			Patch713: coreutils-4.5.3-langinfo.patch
			Patch900: coreutils-setsid.patch
			Patch907: coreutils-5.2.1-runuser.patch
			Patch908: coreutils-getgrouplist.patch
			Patch912: coreutils-overflow.patch
			Patch915: coreutils-split-pam.patch
			Patch917: coreutils-8.4-su-pie.patch
			Patch918: coreutils-8.4-tail-sleepinterval.patch
			Patch919: coreutils-8.4-tac-doublefree.patch
			Patch921: coreutils-8.4-mkdir-modenote.patch
			Patch922: coreutils-8.4-echooctalinfo.patch
			Patch923: coreutils-8.4-dddirectturnoff.patch
			Patch924: coreutils-8.4-tcshsuspend.patch"
	lts6_srpm_epatch || die

	if use acl ; then
		SRPM_PATCHLIST="Patch916: coreutils-getfacl-exit-code.patch
				Patch925: coreutils-8.4-ls-aclnofollow.patch"
		lts6_srpm_epatch || die
	fi

	if use unicode ; then
		SRPM_PATCHLIST="Patch800: coreutils-i18n.patch
				Patch920: coreutils-8.4-sort-monthssigsegv.patch"
		lts6_srpm_epatch || die
	fi

	if use selinux ; then
		SRPM_PATCHLIST="Patch950: coreutils-selinux.patch
				Patch951: coreutils-selinuxmanpages.patch
				Patch952: coreutils-8.4-newmock.patch"
		lts6_srpm_epatch || die
	fi

	epatch "${FILESDIR}/003_all_coreutils-gentoo-uname-v2.patch"
	epatch "${FILESDIR}/010_all_coreutils-tests.patch"
	epatch "${FILESDIR}/030_all_coreutils-more-dir-colors.patch"

	# Since we've patched many .c files, the make process will try to
	# re-build the manpages by running `./bin --help`.  When doing a
	# cross-compile, we can't do that since 'bin' isn't a native bin.
	# Also, it's not like we changed the usage on any of these things,
	# so let's just update the timestamps and skip the help2man step.
	set -- man/*.x
	tc-is-cross-compiler && touch ${@/%x/1}

	eautoreconf
}

src_configure() {
	tc-is-cross-compiler && [[ ${CHOST} == *linux* ]] && export fu_cv_sys_stat_statfs2_bsize=yes #311569

	if use s390 ; then
		append-flags "-fPIC -O1"
	else
		append-flags "-fpic"
	fi
		
	use static && append-ldflags -static
	use selinux || export ac_cv_{header_selinux_{context,flash,selinux}_h,search_setfilecon}=no #301782
	# kill/uptime - procps
	# groups/su   - shadow
	# hostname    - net-tools
	econf \
		--with-packager="Gentoo" \
		--with-packager-version="${PVR} (p${PATCH_VER:-0})" \
		--with-packager-bug-reports="http://bugs.gentoo.org/" \
		--enable-install-program="arch" \
		--enable-no-install-program="groups,hostname,kill,su,uptime" \
		--enable-largefile \
		$(use caps || echo --disable-libcap) \
		$(use_enable nls) \
		$(use_enable acl) \
		$(use_enable xattr) \
		$(use_with gmp) \
		|| die "econf"
}

src_test() {
	# Non-root tests will fail if the full path isnt
	# accessible to non-root users
	chmod -R go-w "${WORKDIR}"
	chmod a+rx "${WORKDIR}"

	# coreutils tests like to do `mount` and such with temp dirs
	# so make sure /etc/mtab is writable #265725
	# make sure /dev/loop* can be mounted #269758
	mkdir -p "${T}"/mount-wrappers
	mkwrap() {
		local w ww
		for w in "$@" ; do
			ww="${T}/mount-wrappers/${w}"
			cat <<-EOF > "${ww}"
				#!/bin/sh
				exec env SANDBOX_WRITE="\${SANDBOX_WRITE}:/etc/mtab:/dev/loop" $(type -P $w) "\$@"
			EOF
			chmod a+rx "${ww}"
		done
	}
	mkwrap mount umount

	addwrite /dev/full
	#export RUN_EXPENSIVE_TESTS="yes"
	#export FETISH_GROUPS="portage wheel"
	env PATH="${T}/mount-wrappers:${PATH}" \
	emake -j1 -k check || die "make check failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog* NEWS README* THANKS TODO

	insinto /etc
	newins src/dircolors.hin DIR_COLORS || die

	if [[ ${USERLAND} == "GNU" ]] ; then
		cd "${D}"/usr/bin
		dodir /bin
		# move critical binaries into /bin (required by FHS)
		local fhs="cat chgrp chmod chown cp date dd df echo false ln ls
		           mkdir mknod mv pwd rm rmdir stty sync true uname"
		mv ${fhs} ../../bin/ || die "could not move fhs bins"
		# move critical binaries into /bin (common scripts)
		local com="basename chroot cut dir dirname du env expr head mkfifo
		           mktemp readlink seq sleep sort tail touch tr tty vdir wc yes"
		mv ${com} ../../bin/ || die "could not move common bins"
		# create a symlink for uname in /usr/bin/ since autotools require it
		local x
		for x in ${com} uname ; do
			dosym /bin/${x} /usr/bin/${x} || die
		done
	else
		# For now, drop the man pages, collides with the ones of the system.
		rm -rf "${D}"/usr/share/man
	fi
}

pkg_postinst() {
	ewarn "Make sure you run 'hash -r' in your active shells."
	ewarn "You should also re-source your shell settings for LS_COLORS"
	ewarn "  changes, such as: source /etc/profile"

	# /bin/dircolors sometimes sticks around #224823
	if [ -e "${ROOT}/usr/bin/dircolors" ] && [ -e "${ROOT}/bin/dircolors" ] ; then
		if strings "${ROOT}/bin/dircolors" | grep -qs "GNU coreutils" ; then
			einfo "Deleting orphaned GNU /bin/dircolors for you"
			rm -f "${ROOT}/bin/dircolors"
		fi
	fi
}
