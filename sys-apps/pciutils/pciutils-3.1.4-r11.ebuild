# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/pciutils/pciutils-3.1.4.ebuild,v 1.12 2010/01/30 18:36:57 armin76 Exp $

EAPI="4"

inherit eutils multilib toolchain-funcs rpm lts6-rpm

DESCRIPTION="Various utilities dealing with the PCI bus"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~mj/pciutils.html"
SRPM="pciutils-3.1.4-11.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="network-cron zlib"

DEPEND="zlib? ( sys-libs/zlib )"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"
	epatch "${FILESDIR}"/${P}-install-lib.patch #273489
	epatch "${FILESDIR}"/${PN}-2.2.7-update-pciids-both-forms.patch
	sed -i -e "/^LIBDIR=/s:/lib:/$(get_libdir):" Makefile

#	The following multilib patches have been left out since they
#	are causing issues in Gentoo's build envirnoment.
#
#			Patch8:         pciutils-3.0.2-multilib.patch
#			Patch10:        pciutils-2.2.10-sparc-support.patch
#			Patch11:        pciutils-3.0.1-superh-support.patch
#			Patch12:        pciutils-3.1.2-arm.patch

	SRPM_PATCHLIST="Patch1:         pciutils-2.2.4-buf.patch
			Patch2:         pciutils-2.1.10-scan.patch
			Patch3:         pciutils-havepread.patch
			Patch9:         pciutils-dir-d.patch
			Patch13:        pciutils-3.1.6-capfree.patch
			Patch14:        pciutils-3.1.4-pcie3cap.patch"

	lts6_srpm_epatch || die
}

uyesno() { use $1 && echo yes || echo no ; }
pemake() {
	emake \
		HOST="${CHOST}" \
		CROSS_COMPILE="${CHOST}-" \
		CC="$(tc-getCC)" \
		DNS="yes" \
		IDSDIR="/usr/share/misc" \
		MANDIR="/usr/share/man" \
		PREFIX="/usr" \
		SHARED="yes" \
		STRIP="" \
		ZLIB=$(uyesno zlib) \
		"$@"
}

src_compile() {
	pemake OPT="${CFLAGS}" all || die
}

src_install() {
	pemake DESTDIR="${D}" install install-lib || die
	dodoc ChangeLog README TODO

	if use network-cron ; then
		exeinto /etc/cron.monthly
		newexe "${FILESDIR}"/pciutils.cron update-pciids \
			|| die "Failed to install update cronjob"
	fi

	newinitd "${FILESDIR}"/init.d-pciparm pciparm
	newconfd "${FILESDIR}"/conf.d-pciparm pciparm
}

pkg_postinst() {
	elog "The 'pcimodules' program has been replaced by 'lspci -k'"
}
