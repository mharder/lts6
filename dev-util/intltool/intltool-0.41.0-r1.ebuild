# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/intltool/intltool-0.50.0.ebuild,v 1.7 2012/02/12 14:42:20 armin76 Exp $

EAPI=4

inherit rpm lts6-rpm

DESCRIPTION="Internationalization Tool Collection"
HOMEPAGE="http://edge.launchpad.net/intltool/"
SRPM="intltool-0.41.0-1.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.8.1
	dev-perl/XML-Parser"
RDEPEND="${DEPEND}
	sys-devel/gettext"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: schemas-merge.patch"
	lts6_srpm_epatch || die
}

DOCS=( AUTHORS README TODO doc/I18N-HOWTO )
