# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libgpg-error/Attic/libgpg-error-1.7.ebuild,v 1.11 2011/05/14 21:29:23 arfrever dead $

EAPI="4"

inherit eutils libtool rpm lts6-rpm

DESCRIPTION="Contains error handling functions used by GnuPG software"
HOMEPAGE="http://www.gnupg.org/related_software/libgpg-error"
SRPM="libgpg-error-1.7-4.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="common-lisp nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_prepare() {
	epunt_cxx
	# for BSD?
	elibtoolize
}

DOCS=( AUTHORS ChangeLog NEWS README )

src_configure() {
	econf $(use_enable nls)
}

src_install() {
	default

	if ! use common-lisp; then
		rm -fr "${D}usr/share/common-lisp"
	fi

	# library has no dependencies, so it does not need the .la file
	find "${D}" -name '*.la' -delete
}
