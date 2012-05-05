# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/shared-mime-info/Attic/shared-mime-info-0.70.ebuild,v 1.7 2010/04/11 11:38:15 nixnut Exp $

EAPI="4"
inherit fdo-mime rpm lts6-rpm

DESCRIPTION="The Shared MIME-info Database specification"
HOMEPAGE="http://freedesktop.org/wiki/Software/shared-mime-info"
SRPM="shared-mime-info-0.70-4.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6:2
	>=dev-libs/libxml2-2.4"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	dev-util/intltool
	sys-devel/gettext"

src_unpack() {
	rpm_src_unpack || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-update-mimedb
}

src_compile() {
	# http://bugs.gentoo.org/show_bug.cgi?id=347870
	# https://bugs.freedesktop.org/show_bug.cgi?id=32127
	emake -j1 || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog HACKING NEWS README

	# in prefix, install an env.d entry such that prefix patch is used/added
	if use prefix; then
		echo "XDG_DATA_DIRS=\"${EPREFIX}/usr/share\"" > "${T}"/50mimeinfo
		doenvd "${T}"/50mimeinfo
	fi
}

pkg_postinst() {
	use prefix && export XDG_DATA_DIRS="${EPREFIX}"/usr/share
	fdo-mime_mime_database_update
	elog
	elog "The database format has changed between 0.60 and 0.70."
	elog "You may need to update all your local databases and caches."
	elog "To do so, please run the following commands:"
	elog "(for each user) $ update-mime-database ~/.local/share/mime/"
	elog "(as root)       # update-mime-database /usr/local/share/mime/"
	elog
}
