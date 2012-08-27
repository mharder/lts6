# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/pflogsumm/Attic/pflogsumm-1.1.1.ebuild,v 1.5 2011/06/27 05:56:46 eras dead $

EAPI="4"

inherit rpm lts6-rpm

DESCRIPTION="Pflogsumm is a log analyzer for Postfix logs"
HOMEPAGE="http://jimsun.linxnet.com/postfix_contrib.html"

SRPM="postfix-2.6.6-2.2.el6_1.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~amd64 ~sparc ~x86"
IUSE=""
DEPEND="dev-lang/perl
		dev-perl/Date-Calc"

src_unpack() {
	# The source for pflogsumm is in the postfix SRPM package.
	# Explicitly unpack only the pflogsumm sources.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"
	unpack "./${PN}-${PV}.tar.gz" || die "unpack failed!"
}

src_prepare() {
	SRPM_PATCHLIST="Patch9: pflogsumm-1.1.1-datecalc.patch"
	lts6_srpm_epatch || die
}

src_install() {
	dodoc README ToDo ChangeLog pflogsumm-faq.txt
	doman pflogsumm.1
	dobin pflogsumm.pl
}
