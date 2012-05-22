# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tiff/Attic/tiff-3.9.4-r1.ebuild,v 1.2 2011/04/23 16:38:13 nerdboy Exp $

EAPI=4
inherit eutils libtool rpm lts6-rpm

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images"
HOMEPAGE="http://www.remotesensing.org/libtiff/"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+cxx jbig jpeg static-libs zlib"

SRPM="libtiff-3.9.4-5.el6_2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="jpeg? ( || ( virtual/jpeg-lts6 virtual/jpeg ) )
	jbig? ( media-libs/jbigkit )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}"

SRPM_PATCHLIST="
Patch1: libtiff-acversion.patch
Patch2: libtiff-mantypo.patch
Patch3: libtiff-scanlinesize.patch
Patch4: libtiff-getimage-64bit.patch
Patch5: libtiff-ycbcr-clamp.patch
Patch6: libtiff-3samples.patch
Patch7: libtiff-subsampling.patch
Patch8: libtiff-unknown-fix.patch
Patch9: libtiff-checkbytecount.patch
Patch10: libtiff-tiffdump.patch
Patch11: libtiff-CVE-2011-0192.patch
Patch12: libtiff-CVE-2011-1167.patch
Patch13: libtiff-CVE-2009-5022.patch
Patch14: libtiff-CVE-2012-1173.patch
"

src_prepare() {
	lts6_srpm_epatch || die

	elibtoolize
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable cxx) \
		$(use_enable zlib) \
		$(use_enable jpeg) \
		$(use_enable jbig) \
		--without-x \
		--with-docdir="${EPREFIX}"/usr/share/doc/${PF}
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog README TODO
}

pkg_postinst() {
	if use jbig; then
		echo
		elog "JBIG support is intended for Hylafax fax compression, so we"
		elog "really need more feedback in other areas (most testing has"
		elog "been done with fax).  Be sure to recompile anything linked"
		elog "against tiff if you rebuild it with jbig support."
		echo
	fi
}
