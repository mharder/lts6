# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/Attic/slang-2.2.1.ebuild,v 1.2 2009/12/17 18:36:01 ssuominen dead $

EAPI=4
inherit autotools eutils rpm lts6-rpm

DESCRIPTION="A multi-platform programmer's library designed to allow a developer to create robust software"
HOMEPAGE="http://www.jedsoft.org/slang/"
SRPM="slang-2.2.1-1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="cjk pcre png readline static-libs zlib"

RDEPEND="sys-libs/ncurses
	pcre? ( dev-libs/libpcre )
	png? ( media-libs/libpng )
	cjk? ( dev-libs/oniguruma )
	readline? ( sys-libs/readline )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch1: slang-2.1.4-makefile.patch
			Patch2: slang-nointerlibc2.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-2.1.2-slsh-libs.patch \
		"${FILESDIR}"/${PN}-2.2.1.-uclibc-EL.patch

	eautomake
}

src_configure() {
	local myconf

	if use readline; then
		myconf+=" --with-readline=gnu"
	else
		myconf+=" --with-readline=slang"
	fi

	econf \
		$(use_with cjk onig) \
		$(use_with pcre) \
		$(use_with png) \
		$(use_with zlib z) \
		${myconf}
}

src_compile() {
	emake elf $(use static-libs && echo static)

	pushd slsh >/dev/null
	emake slsh
	popd
}

src_install() {
	emake DESTDIR="${D}" install-elf $(use static-libs && echo install-static)

	rm -rf "${ED}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
