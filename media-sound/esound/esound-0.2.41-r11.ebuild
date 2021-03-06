# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/esound/Attic/esound-0.2.41.ebuild,v 1.11 2012/03/18 12:32:02 pacho dead $

EAPI=2
inherit libtool gnome.org eutils flag-o-matic rpm lts6-rpm

DESCRIPTION="The Enlightened Sound Daemon"
HOMEPAGE="http://www.tux.org/~ricdude/EsounD.html"

SRPM="esound-0.2.41-3.1.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sh ~sparc ~x86 ~x86-fbsd"
IUSE="alsa debug doc ipv6 oss static-libs tcpd"

COMMON_DEPEND=">=media-libs/audiofile-0.2.3
	alsa? ( media-libs/alsa-lib )
	doc?  ( app-text/docbook-sgml-utils )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6-r2 )"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	app-admin/eselect-esd"

src_prepare() {
	SRPM_PATCHLIST="Patch4: esound-0.2.38-drain.patch
			Patch6: esound-0.2.38-fix-open-macro.patch
			Patch7: remove-confusing-spew.patch
			# default to nospawn, so we can kill the esd.conf file
			Patch8: esound-nospawn.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}/${PN}-0.2.39-fix-errno.patch" \
		"${FILESDIR}/${P}-debug.patch"
}

src_configure() {
	# Strict aliasing issues
	append-flags -fno-strict-aliasing

	local myconf

	if ! use alsa; then
		myconf="--enable-oss"
	else
		myconf="$(use_enable oss)"
	fi

	econf \
		--sysconfdir=/etc/esd \
		--htmldir=/usr/share/doc/${PF}/html \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_enable ipv6) \
		$(use_enable debug debugging) \
		$(use_enable alsa) \
		--disable-arts \
		--disable-artstest \
		$(use_with tcpd libwrap) \
		${myconf}
}

src_install() {
	emake -j1 DESTDIR="${D}" install  || die "emake install failed"
	mv "${D}/usr/bin/"{esd,esound-esd}

	dodoc AUTHORS ChangeLog MAINTAINERS NEWS README TIPS TODO

	newconfd "${FILESDIR}/esound.conf.d" esound

	extradepend=""
	use tcpd && extradepend=" portmap"
	use alsa && extradepend="$extradepend alsasound"
	sed -e "s/@extradepend@/$extradepend/" "${FILESDIR}/esound.init.d.2" >"${T}/esound"
	doinitd "${T}/esound"
}

pkg_postinst() {
	eselect esd update --if-unset \
		|| die "eselect failed, try removing /usr/bin/esd and re-emerging."
}
