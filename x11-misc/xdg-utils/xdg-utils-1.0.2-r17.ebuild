# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xdg-utils/Attic/xdg-utils-1.0.2_p20101101.ebuild,v 1.2 2010/11/03 23:56:22 ssuominen Exp $

inherit rpm lts6-rpm

EAPI="4"

DESCRIPTION="Portland utils for cross-platform/cross-toolkit/cross-desktop interoperability"
HOMEPAGE="http://portland.freedesktop.org/"
SRPM="xdg-utils-1.0.2-17.20091016cvs.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="x11-apps/xprop
	x11-apps/xset
	x11-misc/shared-mime-info"
PDEPEND="dev-util/desktop-file-utils"
DEPEND="app-arch/xz-utils"

RESTRICT="test" # root access required

S=${WORKDIR}/${PN}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	# Note: CVE-2008-0386 is already taken care of when using
	# the 20091016cvs sources.
	SRPM_PATCHLIST="Patch0: xdg-utils-wrong-gconftool.patch
			Patch1: xdg-utils-1.0.2-htmlview.patch
			Patch2: xdg-utils-1.1.0-thunderbird-attachments.patch
			Patch3: xdg-utils-1.1.0-thunderbird-to-address.patch
			Patch4: xdg-utils-1.1.x-gawk-unicode.patch
			Patch5: xdg-utils-1.1.x-thunderbird-unescape.patch
			Patch6: xdg-utils-1.1.x-thunderbird-unescape-attachment.patch
			Patch7: xdg-utils-1.1.x-thunderbird-double-quotes.patch"
	lts6_srpm_epatch || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ChangeLog README RELEASE_NOTES TODO || die
	newdoc scripts/README README.scripts || die

	if use doc; then
		dohtml -r scripts/html || die
	fi

	# Install default XDG_DATA_DIRS, bug #264647
	echo 'XDG_DATA_DIRS="/usr/local/share"' > 30xdg-data-local
	echo 'COLON_SEPARATED="XDG_DATA_DIRS XDG_CONFIG_DIRS"' >> 30xdg-data-local
	doenvd 30xdg-data-local || die

	echo 'XDG_DATA_DIRS="/usr/share"' > 90xdg-data-base
	echo 'XDG_CONFIG_DIRS="/etc/xdg"' >> 90xdg-data-base
	doenvd 90xdg-data-base || die
}

pkg_postinst() {
	if ! has_version "x11-libs/gtk+:2"; then
		echo
		elog "Install x11-libs/gtk+:2 if you need the gtk-update-icon-cache command."
		echo
	fi
}
