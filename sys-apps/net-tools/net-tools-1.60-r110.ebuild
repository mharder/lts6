# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/net-tools/net-tools-1.60_p20110409135728.ebuild,v 1.9 2011/07/29 08:43:16 zmedico Exp $

EAPI="3"

inherit flag-o-matic toolchain-funcs eutils rpm lts6-rpm

PATCH_VER="1"
DESCRIPTION="Standard Linux networking tools"
HOMEPAGE="http://net-tools.berlios.de/"

SRPM="net-tools-1.60-110.el6_2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-linux"
IUSE="nls static"

RDEPEND=""
# The Enterprise Linux SRPM packages ethercard-diag in the net-tools package.
DEPEND="${RDEPEND}
	app-arch/xz-utils
	!net-misc/ethercard-diag"

SRPM_PATCHLIST="
Patch1: net-tools-1.57-bug22040.patch
Patch2: net-tools-1.60-miiioctl.patch
Patch3: net-tools-1.60-manydevs.patch
Patch4: net-tools-1.60-virtualname.patch
Patch5: net-tools-1.60-cycle.patch
Patch6: net-tools-1.60-nameif.patch
Patch7: net-tools-1.60-ipx.patch
Patch8: net-tools-1.60-inet6-lookup.patch
Patch9: net-tools-1.60-man.patch
Patch10: net-tools-1.60-gcc33.patch
Patch11: net-tools-1.60-trailingblank.patch
Patch12: net-tools-1.60-interface.patch
Patch14: net-tools-1.60-gcc34.patch
Patch15: net-tools-1.60-overflow.patch
Patch19: net-tools-1.60-siunits.patch
Patch20: net-tools-1.60-trunc.patch
Patch21: net-tools-1.60-return.patch
Patch22: net-tools-1.60-parse.patch
Patch23: net-tools-1.60-netmask.patch
Patch24: net-tools-1.60-ulong.patch
Patch25: net-tools-1.60-bcast.patch
Patch26: net-tools-1.60-mii-tool-obsolete.patch
Patch27: net-tools-1.60-netstat_ulong.patch
Patch28: net-tools-1.60-note.patch
Patch29: net-tools-1.60-num-ports.patch
Patch30: net-tools-1.60-duplicate-tcp.patch
Patch31: net-tools-1.60-statalias.patch
Patch32: net-tools-1.60-isofix.patch
Patch34: net-tools-1.60-ifconfig_ib.patch
Patch35: net-tools-1.60-de.patch
Patch37: net-tools-1.60-pie.patch
Patch38: net-tools-1.60-ifaceopt.patch
Patch39: net-tools-1.60-trim_iface.patch
Patch40: net-tools-1.60-stdo.patch
Patch41: net-tools-1.60-statistics.patch
Patch42: net-tools-1.60-ifconfig.patch
Patch43: net-tools-1.60-arp_overflow.patch
Patch44: net-tools-1.60-hostname_man.patch
Patch45: net-tools-1.60-interface_stack.patch
Patch46: net-tools-1.60-selinux.patch
Patch47: net-tools-1.60-netstat_stop_trim.patch
Patch48: net-tools-1.60-netstat_inode.patch
Patch49: net-tools-1.60-fgets.patch
Patch50: net-tools-1.60-ifconfig_man.patch
Patch51: net-tools-1.60-x25-proc.patch
Patch52: net-tools-1.60-sctp.patch
Patch53: net-tools-1.60-arp_man.patch
Patch54: net-tools-1.60-ifconfig-long-iface-crasher.patch
Patch55: net-tools-1.60-netdevice.patch
Patch56: net-tools-1.60-skip.patch
Patch57: net-tools-1.60-netstat-I-fix.patch
Patch58: net-tools-1.60-nameif_strncpy.patch
Patch59: net-tools-1.60-arp-unaligned-access.patch
Patch60: net-tools-1.60-sctp-quiet.patch
Patch61: net-tools-1.60-remove_node.patch
Patch62: net-tools-1.60-netstat-interfaces-crash.patch
Patch64: net-tools-1.60-ec_hw_null.patch
Patch65: net-tools-1.60-statistics_buffer.patch
Patch66: net-tools-1.60-sctp-addrs.patch
Patch67: net-tools-1.60-i-option.patch
Patch68: net-tools-1.60-a-option.patch
Patch69: net-tools-1.60-clear-flag.patch
Patch70: net-tools-1.60-metric-tunnel-man.patch
Patch71: net-tools-1.60-netstat-probe.patch

# scanf format length fix (non-exploitable)
Patch72: net-tools-1.60-scanf-format.patch

# netstat - avoid name resolution for listening or established sockets (-l)
# by return fast
Patch73: net-tools-1.60-avoid-name-resolution.patch

# netstat - --continuous should flush stdout
Patch74: net-tools-1.60-continous-flush-stdout.patch

# fix some errors so net-tools can be build with DEBUG defined
Patch75: net-tools-1.60-debug-fix.patch

# let the user know that ifconfig can correctly show only first 8 bytes of Infiniband hw address
Patch76: net-tools-1.60-ib-warning.patch

# notes in man pages, saying that these tools are obsolete
Patch77: net-tools-1.60-man-obsolete.patch

# Bug 322901  Sens negating error in man page translation (arp)
Patch78: net-tools-1.60-man-RHEL-bugs.patch

# handle raw IP masqinfo
Patch79: net-tools-1.60-masqinfo-raw-ip.patch

# touch up build system to respect normal toolchain env vars rather than
# requiring people to set random custom ones add missing dependency on
# version.h to libdir target to fix parallel build failures
# convert -idirafter to -I
Patch80: net-tools-1.60-makefile-berlios.patch

# slattach: use fchown() rather than chown() to avoid race between creation
# and permission changing
Patch81: net-tools-1.60-slattach-fchown.patch

# Bug 531702: make ...hostname -s... display host name cut at the first dot
# (no matter if the host name resolves or not)
Patch82: net-tools-1.60-hostname-short.patch

# use <linux/mii.h> and fix Bug #491358
Patch83: net-tools-1.60-mii-refactor.patch

# Bug 567272: ifconfig interface:0 del <IP> will remove the Aliased IP on IA64
Patch84: net-tools-1.60-IA64.patch

# interface: fix IPv6 parsing of interfaces with large indexes (> 255)
Patch85: net-tools-1.60-large-indexes.patch

# netstat -s (statistics.c) now uses unsigned long long (instead of int) to handle 64 bit integers (Bug #580054)
Patch86: net-tools-1.60-statistics-doubleword.patch

# fix memory leak in netstat when run with -c option (Bug #634539)
Patch88: net-tools-1.60-netstat-leak.patch

# Don't rely on eth0 being default network device name.
# Since RHEL-6.1 network devices can have arbitrary names (#682368)
Patch89: net-tools-1.60-arbitrary-device-names.patch

# plipconfig man page and usage output fixes (#694766)
Patch90: net-tools-1.60-plipconfig.patch

# Add -A,--all-fqdns and -I,--all-ip-addresses options to hostname (#705110)
Patch91: net-tools-1.60-allnames.patch

# patch netstat to separate basename of -p only if it is absolute
# path (in order to make argv[0]=sshd pty/0 display as sshd, and not as /0).
# (#725348)
Patch92: net-tools-1.60-netstat-p-basename.patch
"

set_opt() {
	local opt=$1 ans
	shift
	ans=$("$@" && echo y || echo n)
	einfo "Setting option ${opt} to ${ans}"
	sed -i \
		-e "/^bool.* ${opt} /s:[yn]$:${ans}:" \
		config.in || die
}

src_prepare() {
	lts6_srpm_epatch || die

	# Note:  The Enterprise Linux Source Code seems to already utilize
	# most of the modifications provided by 
	# 0002-revert-621a2f376334f8097604b9fee5783e0f1141e66d-for-.patch

	# Patch 0001-prevent-overflows-in-interface-buffers.patch
	# is covered by EL patch net-tools-1.60-overflow.patch

	epatch "${FILESDIR}/${P}-Makefile.patch" || die "Patch Failed..."

	cp "${WORKDIR}/${P}-config.h" "${S}/config.h"
	cp "${WORKDIR}/${P}-config.make" "${S}/config.make"
	cp "${WORKDIR}/ether-wake.c" "${S}"
	cp "${WORKDIR}/ether-wake.8" "${S}/man/en_US/"
	cp "${WORKDIR}/mii-diag.c" "${S}"
	cp "${WORKDIR}/mii-diag.8" "${S}/man/en_US/"
	cp "${WORKDIR}/iptunnel.8" "${S}/man/en_US/"
	cp "${WORKDIR}/ipmaddr.8" "${S}/man/en_US/"

	# Need to translate this to sed or something..
	# %ifarch alpha
	#    perl -pi -e "s|-O2||" Makefile
	# %endif

	mv "${S}"/man/de_DE "${S}"/man/de
	mv "${S}"/man/fr_FR "${S}"/man/fr
	mv "${S}"/man/pt_BR "${S}"/man/pt

	# Remove these obsolete files
	rm "${S}/man/en_US/rarp.8*"
	rm "${S}/man/de/rarp.8*"
	rm "${S}/man/fr/rarp.8*"
	rm "${S}/man/pt/rarp.8*"
}

src_configure() {
	set_opt I18N use nls
	set_opt HAVE_HWIB has_version '>=sys-kernel/linux-headers-2.6'
	if use static ; then
		append-flags -static
		append-ldflags -static
	fi
	tc-export AR CC
	yes "" | ./configure.sh config.in || die
}

src_compile() {
	emake || die "Make failed..."

	# The EL SRPM package adds these two source files adhoc.
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o ether-wake ether-wake.c
	$(tc-getCC) ${CFLAGS} ${LDFLAGS} -o mii-diag mii-diag.c
}

src_install() {
	emake DESTDIR="${ED}" BASEDIR="${ED}" install || die
	dodoc README README.ipv6 TODO

	exeinto /sbin
	doexe ether-wake || die
	doexe mii-diag || die
}
