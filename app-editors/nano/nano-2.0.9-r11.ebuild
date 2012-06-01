# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/nano/nano-2.0.9.ebuild,v 1.9 2009/01/04 17:13:04 vapier Exp $

EAPI="4"

inherit eutils rpm lts6-rpm

DESCRIPTION="GNU GPL'd Pico clone with more functionality"
HOMEPAGE="http://www.nano-editor.org/"

SRPM="nano-2.0.9-7.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="debug justify minimal ncurses nls slang spell unicode"

RDEPEND=">=sys-libs/ncurses-5.2[unicode?]
	nls? ( sys-devel/gettext )
	!ncurses? ( slang? ( sys-libs/slang ) )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	SRPM_PATCHLIST="Patch1:          nano-2.0.9-warnings.patch
			Patch2:          nano-2.0.9-bz582434.patch
			Patch3:          nano-2.0.9-bz582434-inc.patch"
	lts6_srpm_epatch || die

	if [[ ! -e configure ]] ; then
		./autogen.sh || die "autogen failed"
	fi
}

src_configure() {
	local myconf=""
	use ncurses \
		&& myconf="--without-slang" \
		|| myconf="${myconf} $(use_with slang)"

	econf \
		--bindir=/bin \
		--enable-color \
		--enable-multibuffer \
		--enable-nanorc \
		--disable-wrapping-as-root \
		$(use_enable spell speller) \
		$(use_enable justify) \
		$(use_enable debug) \
		$(use_enable nls) \
		$(use_enable unicode utf8) \
		$(use_enable minimal tiny) \
		${myconf} \
		|| die "configure failed"
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc ChangeLog README doc/nanorc.sample AUTHORS BUGS NEWS TODO
	dohtml doc/faq.html
	insinto /etc
	newins doc/nanorc.sample nanorc

	insinto /usr/share/nano
	doins "${FILESDIR}"/*.nanorc || die
	echo $'\n''# include "/usr/share/nano/gentoo.nanorc"' >> "${D}"/etc/nanorc

	dodir /usr/bin
	dosym /bin/nano /usr/bin/nano
}

pkg_postinst() {
	einfo "More helpful info about nano, visit the GDP page:"
	einfo "http://www.gentoo.org/doc/en/nano-basics-guide.xml"
}
