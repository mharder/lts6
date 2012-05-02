# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/lsof/lsof-4.82.ebuild,v 1.9 2010/02/01 17:58:35 hwoarang Exp $

EAPI="4"

inherit flag-o-matic toolchain-funcs rpm lts6-rpm

MY_P=${P/-/_}
DESCRIPTION="Lists open files for running Unix processes"
HOMEPAGE="ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof/"
SRPM="lsof-4.82-4.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="lsof"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="static selinux"

DEPEND="selinux? ( sys-libs/libselinux )"

S=${WORKDIR}/${MY_P}-rh

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	sed -i \
		-e '/LSOF_CFGF="-/s:=":="$LSOF_CFGF :' \
		-e '/^LSOF_CFGF=/s:$:" ${CFLAGS} ${CPPFLAGS}":' \
		-e "/^LSOF_CFGL=/s:\$:' \$(LDFLAGS)':" \
		-e "/^LSOF_RANLIB/s:ranlib:$(tc-getRANLIB):" \
		Configure

	SRPM_PATCHLIST="Patch1: lsof_4.81-threads.patch
			Patch2: lsof_4.83A-selinux-typo.patch
			Patch3: lsof_4.85C-exempt-filesystem.patch
			Patch4: lsof_4.85-multi-e-option.patch
			Patch5: lsof_4.82-nfs-warn.patch"
	lts6_srpm_epatch || die
}

yesno() { use $1 && echo y || echo n ; }
target() { use kernel_FreeBSD && echo freebsd || echo linux ; }

src_configure() {
	touch .neverInv
	LINUX_HASSELINUX=$(yesno selinux) \
	LSOF_CC=$(tc-getCC) \
	LSOF_AR="$(tc-getAR) rc" \
	./Configure -n $(target) || die
}

src_compile() {
	use static && append-ldflags -static

	LINUX_HASSELINUX=$(yesno selinux) \
	LSOF_CC=$(tc-getCC) \
	LSOF_AR="$(tc-getAR) rc" \
	emake DEBUG="" all || die "emake failed"
}

src_install() {
	dobin lsof || die "dosbin"

	insinto /usr/share/lsof/scripts
	doins scripts/*

	doman lsof.8
	dodoc 00*
}
