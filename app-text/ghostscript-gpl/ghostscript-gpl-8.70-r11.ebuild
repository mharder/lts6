# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ghostscript-gpl/Attic/ghostscript-gpl-8.70-r1.ebuild,v 1.1 2009/08/07 02:22:05 tgurr Exp $

EAPI="4"

inherit autotools eutils versionator flag-o-matic rpm lts6-rpm

DESCRIPTION="GPL Ghostscript - the most current Ghostscript, AFPL, relicensed."
HOMEPAGE="http://ghostscript.com/"

MY_P=${P/-gpl}
PVM=$(get_version_component_range 1-2)
SRPM="ghostscript-8.70-11.el6_2.6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="cairo cups gtk jpeg2k X"

COMMON_DEPEND="app-text/libpaper
	media-libs/fontconfig
	>=media-libs/jpeg-6b
	>=media-libs/libpng-1.2.5
	>=media-libs/tiff-3.7
	>=sys-libs/zlib-1.1.4
	cairo? ( >=x11-libs/cairo-1.2.0 )
	cups? ( >=net-print/cups-1.3.8 )
	gtk? ( >=x11-libs/gtk+-2.0 )
	jpeg2k? ( media-libs/jasper )
	X? ( x11-libs/libXt x11-libs/libXext )
	!app-text/ghostscript-gnu"

DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig"

RDEPEND="${COMMON_DEPEND}
	linguas_ja? ( media-fonts/kochi-substitute )
	linguas_ko? ( media-fonts/baekmuk-fonts )
	linguas_zh_CN? ( media-fonts/arphicfonts )
	linguas_zh_TW? ( media-fonts/arphicfonts )
	>=media-fonts/urw-fonts-2.4.9
	!!media-fonts/gnu-gs-fonts-std"

S="${WORKDIR}/${MY_P}"

LANGS="ja ko zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done
src_unpack() {
	# The rpm eclass doesn't support .xz archives yet.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./ghostscript-8.70.tar.xz" || die
}

# Function to support conversion of manual pages to UTF-8
from8859_1() {
        iconv -f iso-8859-1 -t utf-8 < "$1" > "${1}_"
        mv "${1}_" "$1"
}

src_prepare() {
	# remove internal copies of expat, jasper, jpeg, libpng and zlib
	rm -rf "${S}/expat"
	rm -rf "${S}/jasper"
	rm -rf "${S}/jpeg"
	rm -rf "${S}/libpng"
	rm -rf "${S}/zlib"
	# remove internal urw-fonts
	rm -rf "${S}/Resource/Font"

	SRPM_PATCHLIST="Patch1: ghostscript-multilib.patch
			Patch2: ghostscript-scripts.patch
			Patch3: ghostscript-noopt.patch
			Patch4: ghostscript-fPIC.patch
			Patch5: ghostscript-runlibfileifexists.patch
			Patch6: ghostscript-system-jasper.patch
			Patch7: ghostscript-pksmraw.patch
			Patch8: ghostscript-jbig2dec-nullderef.patch
			Patch9: ghostscript-gs-executable.patch
			Patch10: ghostscript-CVE-2009-4270.patch
			Patch11: ghostscript-vsnprintf.patch
			Patch12: ghostscript-gdevcups-y-axis.patch
			Patch13: ghostscript-scan-max-name-length.patch
			Patch14: ghostscript-CVE-2010-1628.patch
			Patch15: ghostscript-iname-segfault.patch
			Patch16: ghostscript-Fontmap.local.patch
			Patch17: ghostscript-hyperlinks.patch
			Patch18: ghostscript-pxl-landscape.patch
			Patch19: ghostscript-CVE-2010-2055.patch
			Patch20: ghostscript-CVE-2009-3743.patch
			Patch21: ghostscript-CVE-2010-4054.patch"
	lts6_srpm_epatch || die

	# Gentoo patches
	# respect LDFLAGS, bug #209803
	epatch "${FILESDIR}/${PN}-8.64-respect-gsc-ldflags.patch"

	if ! use gtk ; then
		sed -i "s:\$(GSSOX)::" base/*.mak || die "gsx sed failed"
		sed -i "s:.*\$(GSSOX_XENAME)$::" base/*.mak || die "gsxso sed failed"
	fi

	# search path fix
	sed -i -e "s:\$\(gsdatadir\)/lib:/usr/share/ghostscript/${PVM}/$(get_libdir):" \
		-e 's:$(gsdir)/fonts:/usr/share/fonts/default/ghostscript/:' \
		-e "s:exdir=.*:exdir=/usr/share/doc/${PF}/examples:" \
		-e "s:docdir=.*:docdir=/usr/share/doc/${PF}/html:" \
		-e "s:GS_DOCDIR=.*:GS_DOCDIR=/usr/share/doc/${PF}/html:" \
		base/Makefile.in base/*.mak || die "sed failed"

	# Convert manual pages to UTF-8
	for i in man/de/*.1; do from8859_1 "$i"; done

	cd "${S}"
	eautoreconf

	cd "${S}/ijs"
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable cairo) \
		$(use_enable cups) \
		$(use_enable gtk) \
		$(use_with jpeg2k jasper) \
		$(use_with X x) \
		--disable-compile-inits \
		--enable-dynamic \
		--enable-fontconfig \
		--with-drivers=ALL \
		--with-ijs \
		--with-jbig2dec \
		--with-libpaper

	cd "${S}/ijs"
	econf || die "ijs econf failed"
}

src_compile() {
	emake -j1 so all || die "emake failed"

	cd "${S}/ijs"
	emake || die "ijs emake failed"
}

src_install() {
	# parallel install is broken, bug #251066
	emake -j1 DESTDIR="${D}" install-so install || die "emake install failed"

	# remove gsc in favor of gambit, bug #253064
	rm -rf "${D}/usr/bin/gsc"

	rm -rf "${D}/usr/share/doc/${PF}/html/"{README,PUBLIC}
	dodoc doc/README || die "dodoc install failed"

	cd "${S}/ijs"
	emake DESTDIR="${D}" install || die "emake ijs install failed"

	# Rename an original cidfmap to cidfmap.GS
	mv "${D}/usr/share/ghostscript/${PVM}/Resource/Init/cidfmap"{,.GS}

	# Install our own cidfmap to allow the separated cidfmap
	insinto "/usr/share/ghostscript/${PVM}/Resource/Init"
	doins "${WORKDIR}/CIDFnmap" || die "doins CIDFnmap failed"
	doins "${WORKDIR}/cidfmap" || die "doins cidfmap failed"
	for X in ${LANGS} ; do
		if use linguas_${X} ; then
			doins "${WORKDIR}/fontmaps/cidfmap.${X}" || die "doins cidfmap.${X} failed"
		fi
	done
}
