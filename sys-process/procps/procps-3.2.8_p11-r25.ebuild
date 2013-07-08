# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/procps/procps-3.2.8_p11.ebuild,v 1.9 2012/02/01 10:28:56 ssuominen Exp $

EAPI="5"

inherit flag-o-matic eutils toolchain-funcs multilib rpm lts6-rpm

MY_PV=${PV%_p*}
MY_P="${PN}-${MY_PV}"
DESCRIPTION="Standard informational utilities and process-handling tools"
HOMEPAGE="http://procps.sourceforge.net/"

SRPM="procps-3.2.8-25.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="unicode selinux"

RDEPEND=">=sys-libs/ncurses-5.2-r2[unicode?]"

SRPM_PATCHLIST="
# Patch1: procps-3.2.7-selinux.patch
Patch2: procps-3.2.7-misc.patch
Patch3: procps-3.2.7-FAQ.patch
# Patch4: procps-3.2.7-selinux-workaround.patch
Patch6: procps-3.2.7-noproc.patch
Patch7: procps-3.2.7-pseudo.patch
Patch8: procps-3.2.7-0x9b.patch
# 157725 - sysctl -A returns an error
Patch9: procps-3.2.7-sysctl-writeonly.patch
# 161449 - top ignores user and system toprc
Patch10: procps-3.2.7-top-rc.patch
# 161303 - top failed when remove cpus
# 186017 - Top Cpu0 line never updates on single processor machine
Patch11: procps-3.2.7-top-remcpu.patch
# 177453 - for VIRT use proc->vm_size rather then proc->size (workaround)
Patch14: procps-3.2.7-top-env-vmsize.patch
# 174619 - workaround for reliable Cpu(s) data in the first loop
Patch15: procps-3.2.7-top-env-cpuloop.patch
# 185299 - cpu steal time support
Patch16: procps-3.2.7-vmstat-cpusteal.patch
# 134516 - ps ignores /proc/#/cmdline if contents 2047 bytes
Patch17: procps-3.2.7-longcmd.patch
# 189349 - 32bit vmstat on 64bit kernel
Patch18: procps-3.2.7-vmstat-pgpg.patch
# 212637 - sysctl using deprecated syscall
# 228870 - process sysctl is using deprecated sysctl ...
Patch21: procps-3.2.7-sysctl-ignore.patch
# 140975 - top corrupts screen when sorting on first column
Patch22: procps-3.2.7-top-sorthigh.path
# 234546 - 'w' doesn't give correct information about what's being run.
Patch23: procps-3.2.7-w-best.patch
# 183029 - watch ignores unicode characters
Patch24: procps-3.2.7-watch-unicode.patch
# 222251 - STIME can jitter by one second
Patch26: procps-3.2.7-ps-stime.patch
#244152 - ps truncates eip and esp to 32-bit values on 64-bit systems
Patch28: procps-3.2.7-ps-eip64.patch
#244960 - ps manpage formatted incorrectly
Patch29: procps-3.2.7-psman.patch
#185994 - error when using 'Single Cpu = Off' option
Patch31: procps-3.2.7-top-cpu0.patch
#354001 - CPU value in top is reported as an integer
Patch32: procps-3.2.7-top-cpuint.patch
#296471 - update top man page
Patch33: procps-3.2.7-top-manpage.patch
#440694 - strange text after selecting few field
Patch34: procps-3.2.7-top-clrscr.patch
#435453 - errors with man -t formatting of ps man page
Patch35: procps-3.2.7-ps-man-fmt.patch
#472783 - 'vmstat -p <partition name>', 
# the detailed statistics of the partition name is not output.
Patch36: procps-3.2.7-vmstat-partstats-long.patch
# Fix vmstat header to be 80 chars not 81
Patch37: procps-3.2.7-vmstat-header.patch
# rhel bug #475963: slabtop -o should display the info once
Patch38: procps-3.2.7-slabtop-once.patch
#476134 - added timestamp to vmstat with new option -t
Patch39: procps-3.2.7-vmstat-timestamp.patch
#manual page updated to document the -t functionality
Patch40: procps-3.2.7-vmstat-timestamp-manpage.patch
#added cgroup display to ps
Patch41: procps-3.2.7-ps-cgroup.patch
# 'requested writes' display in partition statistics
Patch42: procps-3.2.7-vmstat-partstats-reqwrites.patch
# '-l' option of 'free' documented
Patch43: procps-3.2.7-free-hlmem.patch
# enable core dump generation
Patch44: procps-enable-core.patch
#554721 -  procps states a bug is hit when receiving a signal 
Patch45: procps-3.2.7-no-bug-on-sig.patch
#554674 -  vmstat command with -n and -m does not display header even once 
Patch46: procps-3.2.8-vmstat-mn.patch
#479703 -  [RFE] Additional option for 'top' 
Patch47: procps-3.2.8-rhel6-usedmem.patch
#565971 -  double free or corruption in ps
Patch48: procps-3.2.8-double-free.patch
#564371 -  Enhance top to display in MB vs KB
Patch49: procps-3.2.7-top-memunit.patch
#578799 - vmstat -SM doesn't work but vmstat -S M does
Patch50: procps-3.2.7-vmstat-sm.patch
#580877 - negative ETIME field in ps
Patch51: procps-3.2.8-etime.patch
#583629 - pmap does not display RSS values for a pid
Patch52: procps-3.2.8-pmap-smaps.patch
#583625 - document that usernames exceeding column width
#         are substituted with user ID
Patch53: procps-3.2.7-ps-manpage-uid.patch
#581547 - add vmstat -w option for wider output
Patch54: procps-3.2.8-vmstat-width.patch
Patch55: procps-3.2.7-width-man.patch
#585938 - [abrt] crash in procps-3.2.8-3.fc12
Patch56: procps-3.2.8-setlocale.patch
#596948  - vmstat disk device field is not long enough
Patch57: procps-3.2.8-vmstat-devlen.patch
#598054  - add descriptions of columns to pmap(1) man page
Patch58: procps-3.2.8-pmap-man.patch
#fixes sorting in ps command
Patch59: procps-3.2.8-ps-sort.patch
#fixes #574413
Patch60: procps-3.2.8-pcpu-max-value.patch
#fixes 622389
Patch61: procps-3.2.7-sysctl-man-tbl.patch
#fixes #684031
Patch62: procps-3.2.8-vmstat-leaks.patch
#fixes #692397 - wrong formatting of ps man page
Patch63: procps-3.2.8-ps-man-format.patch
#fixes #709684 - procps/top SWAP statistics makes no sense
Patch64: procps-3.2.8-top-swap.patch
#690078 - selinux is now build time linked
# Patch65: procps-3.2.8-libselinux.patch
#697935 - [RFE] Restore support for partial sysctl keys
Patch66: procps-sysctl-partial-keys-einval.patch
#701710 - vmstat does not print out correct free page count on 8TB SGI system
Patch67: procps-3.2.8-vmstat-long.patch
#736023 - Common realloc mistake: 'screen' nulled but not freed upon failure
Patch68: procps-tload-screen-realloc.patch
#746997 - top utility can't sort by memory usage in batch mode
Patch69: procps-3.2.7-top-batchmem.patch
#746997 follow-up
Patch70: procps-top-man-switches-amM.patch
#851664 - vmstat -S M 1' and 'vmstat -S m 1' erronously output
#         constant 'si' and 'so' value of 0 (RHEL 6)
Patch71: procps-3.2.7-si-so-mM-unitconvert.patch
#875077 - vmstat crashing on s390x
Patch72: procps-3.2.8-vmstat-sigfpe-zeroticks.patch
"

S=${WORKDIR}/${MY_P}

src_prepare() {
	# local p d="${WORKDIR}"/debian/patches
	# pushd "${d}" >/dev/null
	# # makefile_dev_null: this bug is actually in gcc and is already fixed
	# for p in $(use unicode || echo watch_{unicode,ansi_colour}) makefile_dev_null ; do
	#	rm ${p}.patch || die
	#	sed -i "/^${p}/d" series || die
	# done
	# popd >/dev/null
	# EPATCH_SOURCE="${d}" \
	# epatch $(<"${d}"/series)
	# fixup debian watch_exec_beep.patch
	# sed -i '1i#include <sys/wait.h>' watch.c || die

	lts6_srpm_epatch || die

	if use selinux; then
		SRPM_PATCHLIST="Patch1: procps-3.2.7-selinux.patch
				Patch4: procps-3.2.7-selinux-workaround.patch
				Patch65: procps-3.2.8-libselinux.patch"
		lts6_srpm_epatch || die
	fi

	epatch "${FILESDIR}"/${PN}-3.2.7-proc-mount.patch
	# epatch "${FILESDIR}"/${PN}-3.2.3-noproc.patch
	epatch "${FILESDIR}"/${PN}-3.2.8-toprc-fixup.patch
	epatch "${FILESDIR}"/${PN}-3.2.8-r2-forest-prefix.patch
	epatch "${FILESDIR}"/${PN}-3.2.8-time_t.patch

	# Clean up the makefile
	#  - we do stripping ourselves
	#  - punt fugly gcc flags
	sed -i \
		-e '/install/s: --strip : :' \
		-e '/ALL_CFLAGS += $(call check_gcc,-fweb,)/d' \
		-e '/ALL_CFLAGS += $(call check_gcc,-Wstrict-aliasing=2,)/s,=2,,' \
		-e "/^lib64/s:=.*:=$(get_libdir):" \
		-e 's:-m64::g' \
		Makefile || die "sed Makefile"

	# mips 2.4.23 headers (and 2.6.x) don't allow PAGE_SIZE to be defined in
	# userspace anymore, so this patch instructs procps to get the
	# value from sysconf().
	epatch "${FILESDIR}"/${PN}-mips-define-pagesize.patch

	# lame unicode stuff checks glibc defines
	sed -i "s:__GNU_LIBRARY__ >= 6:0 == $(use unicode; echo $?):" proc/escape.c || die
}

src_compile() {
	replace-flags -O3 -O2
	emake \
		CC="$(tc-getCC)" \
		CPPFLAGS="${CPPFLAGS}" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		|| die "make failed"
}

src_install() {
	emake \
		ln_f="ln -sf" \
		ldconfig="true" \
		DESTDIR="${D}" \
		install \
		|| die "install failed"

	insinto /usr/include/proc
	doins proc/*.h || die

	dodoc sysctl.conf BUGS NEWS TODO ps/HACKING

	# compat symlink so people who shouldnt be using libproc can #170077
	dosym libproc-${MY_PV}.so /$(get_libdir)/libproc.so || die
}
