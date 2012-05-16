# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/Attic/file-5.04.ebuild,v 1.10 2011/04/07 20:41:09 arfrever Exp $

EAPI="2"
PYTHON_DEPEND="python? 2"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="3.*"

inherit eutils distutils libtool flag-o-matic rpm lts6-rpm

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

SRPM="file-5.04-13.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="python"

src_prepare() {
	SRPM_PATCHLIST="Patch0: file-4.21-pybuild.patch
			Patch1: file-5.00-devdrv.patch
			Patch2: file-5.00-mdmp.patch
			Patch3: file-5.04-separ.patch
			Patch4: file-5.04-filesystem.patch
			Patch5: file-5.04-ruby-modules.patch
			Patch6: file-5.04-squashfs.patch
			Patch7: file-5.04-ulaw-segfault.patch
			Patch8: file-5.04-core-trim.patch
			Patch9: file-5.04-html-regression.patch
			Patch10: file-5.04-differentiate-gfs1-gfs2.patch
			Patch11: file-5.04-zip64.patch
			Patch12: file-5.04-volume_key.patch
			Patch13: file-5.04-text-string.patch
			Patch14: file-5.04-python-diff-magic.patch
			Patch15: file-5.04-man-return-code.patch
			Patch16: file-5.04-webm.patch
			Patch17: file-5.04-rpm.patch
			Patch18: file-5.04-s390-kernel.patch
			Patch19: file-5.04-core-prpsinfo.patch
			Patch20: file-5.04-python-regex.patch
			Patch21: file-5.04-man-page.patch
			Patch22: file-5.04-latex-improve.patch
			Patch23: file-5.04-text-fix.patch
			Patch24: file-5.04-elf-header-size.patch
			Patch25: file-4.17-i64-swap.patch
			Patch26: file-4.17-rpm-name.patch
			Patch27: file-5.04-bios.patch
			Patch28: file-5.04-generic-msdos.patch
			Patch29: file-5.04-lzma.patch
			Patch30: file-5.04-python-func.patch
			Patch31: file-localmagic.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-4.15-libtool.patch #99593

	elibtoolize
	epunt_cxx

	# make sure python links against the current libmagic #54401
	sed -i "/library_dirs/s:'\.\./src':'../src/.libs':" python/setup.py
	# dont let python README kill main README #60043
	mv python/README{,.python}
}

src_configure() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	econf
}

src_compile() {
	emake || die

	use python && cd python && distutils_src_compile
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc ChangeLog MAINT README

	use python && cd python && distutils_src_install
}

pkg_postinst() {
	use python && distutils_pkg_postinst
}

pkg_postrm() {
	use python && distutils_pkg_postrm
}
