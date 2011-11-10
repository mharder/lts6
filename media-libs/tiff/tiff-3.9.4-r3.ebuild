# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/tiff/Attic/tiff-3.9.4-r1.ebuild,v 1.2 2011/04/23 16:38:13 nerdboy Exp $

EAPI=3
inherit eutils libtool rpm lts6-rpm

DESCRIPTION="Library for manipulation of TIFF (Tag Image File Format) images"
HOMEPAGE="http://www.remotesensing.org/libtiff/"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="+cxx jbig jpeg static-libs zlib"

SRPM="libtiff-3.9.4-1.el6_0.3.src.rpm"
SRC_URI="http://ftp.scientificlinux.org/linux/scientific/6.1/SRPMS/vendor/${SRPM}"

RDEPEND="jpeg? ( virtual/jpeg )
	jbig? ( media-libs/jbigkit )
	zlib? ( sys-libs/zlib )"

DEPEND="${RDEPEND}"

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"
	lts6_rpm_spec_epatch "${WORKDIR}"/libtiff.spec || die
}

src_prepare() {
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
