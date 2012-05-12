# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/iputils/Attic/iputils-20071127-r2.ebuild,v 1.3 2011/02/19 18:09:05 vapier dead $

EAPI="4"

inherit flag-o-matic eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="http://www.linux-foundation.org/en/Net:Iputils"
SRPM="iputils-20071127-16.el6.src.rpm"
SRPM_SUB_PKG="${PN}-s20071127.tar.bz2"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~amd64-linux ~x86-linux"
IUSE="doc idn ipv6 SECURITY_HAZARD static"

RDEPEND="!net-misc/rarpd
	idn? ( net-dns/libidn )"
DEPEND="virtual/os-headers
	app-text/docbook-sgml-utils
	doc? (
		app-text/openjade
		dev-perl/SGMLSpm
		app-text/docbook-sgml-dtd
	)"

S=${WORKDIR}/${PN}-s${PV}

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${SRPM_SUB_PKG}" || die
}

src_prepare() {
	# Omit Patch7: iputils-20070202-idn.patch in favor of
	#   enhanced Gentoo version of same patch.
	#
	# Omit Patch5: iputils-ifenslave.patch
	#   This goes with net-misc/ifenslave

	# The following two patches were left out
	# in favor of a rebuilt iputils-20071127-flowlabel-v2.patch
	# and the changes in 20070202-idn patch:
	# Patch17: iputils-20071127-flowlabel.patch
	# Patch19: iputils-20071127-ping_flags.patch

	# Omit Patch0: iputils-20020927-rh.patch
	#   Use Gentoo 20070202-makefile.patch instead.

	SRPM_PATCHLIST="Patch1: iputils-20020124-countermeasures.patch
			Patch2: iputils-20020927-addrcache.patch
			Patch3: iputils-20020927-ping-subint.patch
			Patch4: iputils-ping_cleanup.patch
			Patch6: iputils-20020927-arping-infiniband.patch
			Patch8: iputils-20070202-open-max.patch
			Patch9: iputils-20070202-traffic_class.patch
			Patch10: iputils-20070202-arping_timeout.patch
			Patch11: iputils-20071127-output.patch
			Patch12: iputils-20070202-ia64_align.patch
			Patch13: iputils-20071127-warnings.patch
			Patch14: iputils-20071127-typing_bug.patch
			Patch15: iputils-20071127-corr_type.patch
			Patch16: iputils-20071127-timeout.patch
			Patch18: iputils-20071127-dosping.patch
			Patch20: iputils-20071127-resolve.patch
			Patch21: iputils-20071127-rdisc_alias.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${P}-gcc34.patch
	epatch "${FILESDIR}"/021109-uclibc-no-ether_ntohost.patch
	epatch "${FILESDIR}"/${PN}-20070202-makefile.patch
	epatch "${FILESDIR}"/${P}-kernel-ifaddr.patch
	epatch "${FILESDIR}"/${PN}-20060512-linux-headers.patch
	# Use EL patch instead.
	# epatch "${FILESDIR}"/${PN}-20070202-no-open-max.patch #195861
	epatch "${FILESDIR}"/${PN}-20070202-idn.patch #218638
	epatch "${FILESDIR}"/${P}-flowlabel-v2.patch
	use SECURITY_HAZARD && epatch "${FILESDIR}"/${PN}-20071127-nonroot-floodping.patch
	use static && append-ldflags -static
	use ipv6 || sed -i -e 's:IPV6_TARGETS=:#IPV6_TARGETS=:' Makefile
	export IDN=$(use idn && echo yes)
}

src_compile() {
	tc-export CC
	emake || die "make main failed"

	emake man || die "make man failed!"
	# We include the extra check for docbook2html
	# because when we emerge from a stage1/stage2,
	# it may not exist #23156
	if use doc && type -P docbook2html >/dev/null ; then
		emake -j1 html || die
	fi
}

src_install() {
	into /
	dobin ping || die "ping"
	use ipv6 && dobin ping6
	dosbin arping || die "arping"
	into /usr
	dosbin tracepath || die "tracepath"
	use ipv6 && dosbin trace{path,route}6
	dosbin clockdiff rarpd rdisc ipg tftpd || die "misc sbin"

	fperms 4711 /bin/ping
	use ipv6 && fperms 4711 /bin/ping6 /usr/sbin/traceroute6

	dodoc INSTALL RELNOTES

	use ipv6 \
		&& dosym ping.8 /usr/share/man/man8/ping6.8 \
		|| rm -f doc/*6.8
	rm -f doc/setkey.8
	doman doc/*.8

	use doc && dohtml doc/*.html
}
