# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/xz-utils/xz-utils-4.999.9_beta.ebuild,v 1.14 2010/06/19 00:36:37 abcd Exp $

# Remember: we cannot leverage autotools in this ebuild in order
#           to avoid circular deps with autotools

EAPI="4"

inherit eutils rpm lts6-rpm

MY_P="${PN/-utils}-${PV/_}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
S=${WORKDIR}/${MY_P}

DESCRIPTION="utils for managing LZMA compressed files"
HOMEPAGE="http://tukaani.org/xz/"

SRPM="xz-4.999.9-0.3.beta.20091007git.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="nls static-libs +threads"

RDEPEND="!app-arch/lzma
	!app-arch/lzma-utils
	!<app-arch/p7zip-4.57"
DEPEND="${RDEPEND}"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	# A workaround is necessary to address an interesting
	# Enterpris Linux SRPM issue.
	# The Enterprise Linux SRPM for xz-utils is itself
	# compressed in an tar.xz file.  So we can't inherit
	# xz-utils in it's own ebuild.
	# In an RPM development environment, I suppose it is typical
	# to assume you're virtually bootstrapping everything.
	# Soln: Use an explicit tar command to unpack the file.
	tar xf "./xz-4.999.9beta.20091007git.tar.xz" --use-compress-program=xz || die
}

src_configure() {
	econf \
		--enable-dynamic=yes \
		$(use_enable nls) \
		$(use_enable threads) \
		$(use_enable static-libs static)
}

src_install() {
	emake install DESTDIR="${D}" || die
	rm "${D}"/usr/share/doc/xz/COPYING* || die
	mv "${D}"/usr/share/doc/{xz,${PF}} || die
	dodoc AUTHORS ChangeLog NEWS README THANKS
}
