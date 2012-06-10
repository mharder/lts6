# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/tcp-wrappers/tcp-wrappers-7.6-r8.ebuild,v 1.25 2010/10/08 02:20:06 leio Exp $

EAPI="4"

inherit eutils flag-o-matic toolchain-funcs rpm lts6-rpm

MY_P="${P//-/_}"
PATCH_VER="1.0"
DESCRIPTION="A security tool which acts as a wrapper for TCP daemons"
HOMEPAGE="ftp://ftp.porcupine.org/pub/security/index.html"

SRPM="tcp_wrappers-7.6-57.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="tcp_wrappers_license"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="ipv6"

S=${WORKDIR}/${MY_P}

SRPM_PATCHLIST="
Patch0: tcpw7.2-config.patch
Patch1: tcpw7.2-setenv.patch
Patch2: tcpw7.6-netgroup.patch
Patch3: tcp_wrappers-7.6-bug11881.patch
Patch4: tcp_wrappers-7.6-bug17795.patch
Patch5: tcp_wrappers-7.6-bug17847.patch
Patch6: tcp_wrappers-7.6-fixgethostbyname.patch
Patch7: tcp_wrappers-7.6-docu.patch
Patch8: tcp_wrappers-7.6-man.patch
Patch9: tcp_wrappers.usagi-ipv6.patch
Patch10: tcp_wrappers.ume-ipv6.patch
Patch11: tcp_wrappers-7.6-shared.patch
Patch12: tcp_wrappers-7.6-sig.patch
Patch13: tcp_wrappers-7.6-strerror.patch
Patch14: tcp_wrappers-7.6-ldflags.patch
Patch15: tcp_wrappers-7.6-fix_sig-bug141110.patch
Patch16: tcp_wrappers-7.6-162412.patch
Patch17: tcp_wrappers-7.6-220015.patch
Patch18: tcp_wrappers-7.6-restore_sigalarm.patch
Patch19: tcp_wrappers-7.6-siglongjmp.patch
Patch20: tcp_wrappers-7.6-sigchld.patch
Patch21: tcp_wrappers-7.6-196326.patch
Patch22: tcp_wrappers_7.6-249430.patch
Patch23: tcp_wrappers-7.6-relro.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	chmod ug+w Makefile

	epatch "${FILESDIR}/10_all_more-headers.patch"
	epatch "${FILESDIR}/${P}-reconcile-makefile.patch"
	epatch "${FILESDIR}/${P}-revert-notipv6-malloc.patch"
}

src_compile() {
	tc-export AR CC RANLIB

	append-flags "-DHAVE_WEAKSYMS"
	use ipv6 && append-flags "-DINET6=1 -Dss_family=__ss_family -Dss_len=__ss_len"
	append-ldflags "-Wl,-z,relro"

	emake \
		REAL_DAEMON_DIR=/usr/sbin \
		MAJOR=0 MINOR=${PV:0:1} REL=${PV:2:3} \
		config-check || die "emake config-check failed"

	emake \
		REAL_DAEMON_DIR=/usr/sbin \
		MAJOR=0 MINOR=${PV:0:1} REL=${PV:2:3} \
		linux || die "emake linux failed"
}

src_install() {
	dosbin tcpd tcpdchk tcpdmatch safe_finger try-from || die

	doman *.[358]
	dosym hosts_access.5 /usr/share/man/man5/hosts.allow.5
	dosym hosts_access.5 /usr/share/man/man5/hosts.deny.5

	insinto /usr/include
	doins tcpd.h

	into /usr
	dolib.a libwrap.a

	into /
	newlib.so libwrap.so libwrap.so.0.${PV}
	dosym libwrap.so.0.${PV} /$(get_libdir)/libwrap.so.0
	dosym libwrap.so.0 /$(get_libdir)/libwrap.so
	# bug #4411
	gen_usr_ldscript libwrap.so || die "gen_usr_ldscript failed"

	dodoc BLURB CHANGES DISCLAIMER README* "${FILESDIR}"/hosts.allow.example
}
