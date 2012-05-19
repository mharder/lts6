# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/keyutils/keyutils-1.4-r1.ebuild,v 1.3 2011/07/08 19:41:49 mattst88 Exp $

EAPI=4

inherit multilib eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Linux Key Management Utilities"
HOMEPAGE="http://people.redhat.com/~dhowells/keyutils/"

SRPM="keyutils-1.4-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~arm-linux ~ia64-linux ~x86-linux"
IUSE=""

DEPEND="!prefix? ( >=sys-kernel/linux-headers-2.6.11 )"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.2-makefile-fixup.patch
	epatch "${FILESDIR}"/${P}-fix-null-rpath.patch
	sed -i \
		-e '/CFLAGS/s|:= -g -O2|+=|' \
		Makefile || die
}

src_configure() {
	:
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS} -Wl,-z,relro" \
		NO_ARLIB=1 \
		NO_GLIBC_KEYERR=1 \
		LIBDIR="/$(get_libdir)" \
		USRLIBDIR="/usr/$(get_libdir)" \
		|| die "emake failed"
}

src_install() {
	emake \
		NO_ARLIB=1 \
		DESTDIR="${ED}" \
		LIBDIR="/$(get_libdir)" \
		USRLIBDIR="/usr/$(get_libdir)" \
		install || die
	dodoc README

	gen_usr_ldscript libkeyutils.so
}
