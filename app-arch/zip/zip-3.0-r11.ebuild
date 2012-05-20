# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zip/zip-3.0-r1.ebuild,v 1.11 2012/05/09 13:06:57 aballier Exp $

EAPI="4"
inherit toolchain-funcs eutils flag-o-matic rpm lts6-rpm

MY_P="${PN}${PV//.}"
DESCRIPTION="Info ZIP (encryption support)"
HOMEPAGE="http://www.info-zip.org/"

SRPM="zip-3.0-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="Info-ZIP"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="bzip2 crypt natspec unicode"

RDEPEND="bzip2? ( app-arch/bzip2 )
	natspec? ( dev-libs/libnatspec )"
DEPEND="${RDEPEND}
	app-arch/unzip"

S=${WORKDIR}/${MY_P}

SRPM_PATCHLIST="
# This patch will probably be merged to zip 3.1
# http://www.info-zip.org/board/board.pl?m-1249408491/
# Note: Use the Gentoo version of the same patch
#       zip-3.0-exec-stack.patch
# Patch1: zip-3.0-exec-shield.patch
# Not upstreamed.
Patch2: zip-3.0-currdir.patch
# Not upstreamed.
Patch3: zip-3.0-time.patch"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-3.0-no-crypt.patch #238398
	epatch "${FILESDIR}"/${PN}-3.0-pic.patch
	epatch "${FILESDIR}"/${PN}-3.0-exec-stack.patch
	epatch "${FILESDIR}"/${PN}-3.0-build.patch
	use natspec && epatch "${FILESDIR}"/${PN}-3.0-natspec.patch #275244

	lts6_srpm_epatch || die
}

src_compile() {
	use bzip2 || append-flags -DNO_BZIP2_SUPPORT
	use crypt || append-flags -DNO_CRYPT
	use unicode || append-flags -DNO_UNICODE_SUPPORT
	emake \
		CC="$(tc-getCC)" \
		LOCAL_ZIP="${CFLAGS} ${CPPFLAGS}" \
		-f unix/Makefile generic \
		|| die
}

src_install() {
	dobin zip zipnote zipsplit || die
	doman man/zip{,note,split}.1
	if use crypt ; then
		dobin zipcloak || die
		doman man/zipcloak.1
	fi
	dodoc BUGS CHANGES README* TODO WHATSNEW WHERE proginfo/*.txt
}
