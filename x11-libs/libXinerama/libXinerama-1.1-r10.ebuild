# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXinerama/libXinerama-1.1.2.ebuild,v 1.9 2012/08/26 18:34:27 armin76 Exp $

EAPI=4
inherit xorg-2 rpm lts6-rpm

DESCRIPTION="X.Org Xinerama library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

SRPM="${PN}-1.1-1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libXext
	x11-proto/xextproto
	>=x11-proto/xineramaproto-1.2"
DEPEND="${RDEPEND}"
