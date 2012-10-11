# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/xterm/Attic/xterm-253.ebuild,v 1.3 2010/01/24 17:39:18 ssuominen dead $

EAPI="4"
inherit multilib rpm lts6-rpm

DESCRIPTION="Terminal Emulator for X Windows"
HOMEPAGE="http://dickey.his.com/xterm/"
SRC_URI="ftp://invisible-island.net/${PN}/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="toolbar truetype unicode Xaw3d"

SRPM="xterm-253-1.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

COMMON_DEPEND="kernel_linux? ( sys-libs/libutempter )
	kernel_FreeBSD? ( || ( >=sys-freebsd/freebsd-lib-9.0 sys-libs/libutempter ) )
	x11-apps/xmessage
	x11-libs/libX11
	x11-libs/libXaw
	x11-libs/libXft
	x11-libs/libxkbfile
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXt
	unicode? ( x11-apps/luit )
	Xaw3d? ( x11-libs/libXaw3d )"
RDEPEND="${COMMON_DEPEND}
	media-fonts/font-misc-misc"
DEPEND="${COMMON_DEPEND}
	x11-proto/xproto"

SRPM_PATCHLIST="
Patch1: xterm-245-resources.patch
Patch3: xterm-226-man-page_paths.patch
"

pkg_setup() {
	DEFAULTS_DIR="${EPREFIX}"/usr/share/X11/app-defaults
}

src_configure() {
	econf \
		--libdir="${EPREFIX}"/etc \
		--x-libraries="${ROOT}usr/$(get_libdir)" \
		--disable-full-tgetent \
		--with-app-defaults=${DEFAULTS_DIR} \
		--disable-setuid \
		--disable-setgid \
		--with-utempter \
		--with-x \
		$(use_with Xaw3d) \
		--disable-imake \
		--enable-256-color \
		--enable-broken-osc \
		--enable-broken-st \
		$(use_enable truetype freetype) \
		--enable-i18n \
		--enable-load-vt-fonts \
		--enable-logging \
		$(use_enable toolbar) \
		$(use_enable unicode mini-luit) \
		$(use_enable unicode luit) \
		--enable-wide-chars \
		--enable-dabbrev \
		--enable-warnings
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README{,.i18n} ctlseqs.txt
	dohtml xterm.log.html
	domenu *.desktop

	# Fix permissions -- it grabs them from live system, and they can
	# be suid or sgid like they were in pre-unix98 pty or pre-utempter days,
	# respectively (#69510).
	# (info from Thomas Dickey) - Donnie Berkholz <spyderous@gentoo.org>
	fperms 0755 /usr/bin/xterm

	# restore the navy blue
	sed -i -e "s:blue2$:blue:" "${ED}"${DEFAULTS_DIR}/XTerm-color
}
