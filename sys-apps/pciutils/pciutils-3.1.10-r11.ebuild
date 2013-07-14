# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.1.10.ebuild,v 1.8 2013/02/22 17:31:31 zmedico Exp $

EAPI="4"

inherit eutils multilib toolchain-funcs rpm lts6-rpm

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://mj.ucw.cz/sw/pciutils/ http://git.kernel.org/?p=utils/pciutils/pciutils.git"
SRPM="pciutils-3.1.10-2.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x64-freebsd ~amd64-linux ~arm-linux ~x86-linux"
IUSE="static-libs zlib"

# Have the sub-libs in RDEPEND with [static-libs] since, logically,
# our libssl.a depends on libz.a/etc... at runtime.
LIB_DEPEND="zlib? ( sys-libs/zlib[static-libs(+)] )"
DEPEND="static-libs? ( ${LIB_DEPEND} )
	!static-libs? ( ${LIB_DEPEND//\[static-libs(+)]} )"
RDEPEND="${DEPEND}
	|| ( sys-apps/hwids sys-apps/hwdata-redhat )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.1.7-install-lib.patch #273489
	epatch "${FILESDIR}"/${PN}-3.1.7-fbsd.patch #262321
	epatch "${FILESDIR}"/${PN}-3.1.9-static-pc.patch

	if use static-libs ; then
		cp -pPR "${S}" "${S}.static" || die
	fi

	# The following multilib patches have been left out since they
	# are causing issues in Gentoo's build envirnoment.
	#
	#		Patch8:         pciutils-3.0.2-multilib.patch
	#		Patch10:        pciutils-2.2.10-sparc-support.patch
	#		Patch11:        pciutils-3.0.1-superh-support.patch
	#		Patch12:        pciutils-3.1.2-arm.patch

	SRPM_PATCHLIST="Patch2:         pciutils-2.1.10-scan.patch
			Patch3:         pciutils-havepread.patch
			Patch9:         pciutils-dir-d.patch"

	lts6_srpm_epatch || die
}

pemake() {
	emake \
		HOST="${CHOST}" \
		CROSS_COMPILE="${CHOST}-" \
		CC="$(tc-getCC)" \
		DNS="yes" \
		IDSDIR='$(SHAREDIR)/misc' \
		MANDIR='$(SHAREDIR)/man' \
		PREFIX="${EPREFIX}/usr" \
		SHARED="yes" \
		STRIP="" \
		ZLIB=$(usex zlib) \
		PCI_COMPRESSED_IDS=0 \
		PCI_IDS=pci.ids \
		LIBDIR="\${PREFIX}/$(get_libdir)" \
		"$@"
}

src_compile() {
	pemake OPT="${CFLAGS}" all
	if use static-libs ; then
		pemake \
			-C "${S}.static" \
			OPT="${CFLAGS}" \
			SHARED="no" \
			lib/libpci.a
	fi
}

src_install() {
	pemake DESTDIR="${D}" install install-lib
	use static-libs && dolib.a "${S}.static/lib/libpci.a"
	dodoc ChangeLog README TODO

	rm "${ED}"/usr/sbin/update-pciids "${ED}"/usr/share/misc/pci.ids \
		"${ED}"/usr/share/man/man8/update-pciids.8*

	newinitd "${FILESDIR}"/init.d-pciparm pciparm
	newconfd "${FILESDIR}"/conf.d-pciparm pciparm
}

pkg_postinst() {
	if [[ ${REPLACING_VERSIONS} ]] && [[ ${REPLACING_VERSIONS} < 3.1.10 ]]; then
		elog "The 'pcimodules' program has been replaced by 'lspci -k'"
		elog ""
		elog "The 'network-cron' USE flag is gone; if you want a more up-to-date"
		elog "pci.ids file, you should use sys-apps/hwids-99999999 (live ebuild)."
	fi
}
