# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jpeg/Attic/jpeg-6b-r8.ebuild,v 1.14 2008/08/16 14:46:39 vapier Exp $

EAPI="4"

inherit libtool eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Library to load, handle and manipulate images in the JPEG format"
HOMEPAGE="http://www.ijg.org/"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="static-libs"

SRPM="libjpeg-6b-46.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/libtool-1.5.10-r4"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	EPATCH_SUFFIX="patch" epatch "${FILESDIR}"/patch || die

	SRPM_PATCHLIST="# The contents of this Patch1 are included in:
			# 51_all_jpeg-Debian-jpeglib.h_c++.patch
			# Patch1: jpeg-c++.patch
			Patch4: libjpeg-cflags.patch
			Patch5: libjpeg-buf-oflo.patch
			Patch6: libjpeg-autoconf.patch"
	lts6_srpm_epatch || die

	cp "${WORKDIR}/configure.in" "${S}" || die

	cp -r "${FILESDIR}"/extra "${WORKDIR}"

	# hrmm. this is supposed to update it.
	# true, the bug is here:
	rm libtool-wrap
	ln -s libtool libtool-wrap
	elibtoolize
}

src_configure() {
	tc-export CC RANLIB AR
	econf \
		--enable-shared \
		$(use_enable static-libs static) \
		--enable-maxmem=64 \
		|| die "econf failed"
}

src_compile() {
	emake || die "make failed"
	emake -C "${WORKDIR}"/extra || die "make extra failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install"
	emake -C "${WORKDIR}"/extra install DESTDIR="${D}" || die "install extra"

	dodoc README install.doc usage.doc wizard.doc change.log \
		libjpeg.doc example.c structure.doc filelist.doc \
		coderules.doc

	find "${ED}" -name '*.la' -exec rm -f '{}' +
}
