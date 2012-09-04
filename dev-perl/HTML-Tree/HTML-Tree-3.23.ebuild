# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTML-Tree/Attic/HTML-Tree-3.23.ebuild,v 1.19 2012/03/31 07:13:49 tove dead $

EAPI=4

MODULE_AUTHOR=PETEK
MODULE_VERSION=3.23
inherit perl-module rpm lts6-rpm

DESCRIPTION="A library to manage HTML-Tree in PERL"

LICENSE="|| ( Artistic GPL-1 GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~ppc-aix ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

SRPM="perl-HTML-Tree-3.23-10.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="
	>=dev-perl/HTML-Tagset-3.03
	>=dev-perl/HTML-Parser-3.46
"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? (
		dev-perl/Test-Fatal
	)
"

SRC_TEST="do"

src_prepare() {
	SRPM_PATCHLIST="Patch0:         missing_close_tag.patch"
	lts6_srpm_epatch || die
}
