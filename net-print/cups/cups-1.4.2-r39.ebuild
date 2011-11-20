# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/Attic/cups-1.4.2-r1.ebuild,v 1.5 2010/03/08 22:20:59 reavertm Exp $

EAPI="3"

inherit eutils flag-o-matic multilib pam versionator rpm lts6-rpm

MY_P=${P/_}

DESCRIPTION="The Common Unix Printing System."
HOMEPAGE="http://www.cups.org/"
SRPM="cups-1.4.2-39.el6_1.1.src.rpm"
SRC_URI="mirror://lts6/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="acl dbus debug gnutls java +jpeg kerberos ldap pam perl php +png python samba slp +ssl static +tiff X xinetd"

COMMON_DEPEND="
	app-text/libpaper
	dev-libs/libgcrypt
	dev-libs/libusb
	acl? (
		kernel_linux? (
			sys-apps/acl
			sys-apps/attr
		)
	)
	dbus? ( sys-apps/dbus )
	gnutls? ( net-libs/gnutls )
	java? ( >=virtual/jre-1.4 )
	jpeg? ( >=media-libs/jpeg-6b:0 )
	kerberos? ( virtual/krb5 )
	ldap? ( net-nds/openldap )
	pam? ( virtual/pam )
	perl? ( dev-lang/perl )
	php? ( dev-lang/php )
	png? ( >=media-libs/libpng-1.2.1 )
	python? ( dev-lang/python )
	slp? ( >=net-libs/openslp-1.0.4 )
	ssl? (
		!gnutls? ( >=dev-libs/openssl-0.9.8g )
	)
	tiff? ( >=media-libs/tiff-3.5.5 )
	xinetd? ( sys-apps/xinetd )
"
DEPEND="${COMMON_DEPEND}"

RDEPEND="${COMMON_DEPEND}
	!net-print/cupsddk
	!virtual/lpr
	X? ( x11-misc/xdg-utils )
"
PDEPEND="
	|| (
		app-text/ghostscript-gpl[cups]
		app-text/ghostscript-gnu[cups]
	)
	>=app-text/poppler-0.12.3-r3[utils]
"

PROVIDE="virtual/lpr"

# upstream includes an interactive test which is a nono for gentoo.
# therefore, since the printing herd has bigger fish to fry, for now,
# we just leave it out, even if FEATURES=test
RESTRICT="${RESTRICT} test"

S="${WORKDIR}/${MY_P}"

LANGS="da de es eu fi fr it ja ko nl no pl pt pt_BR ru sv zh zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

pkg_setup() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp
	enewgroup lpadmin 106
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	# The last patch (cups-lspp.patch) is causing problems,
	# so the patches need to be enumerated."
	cd "${S}"
	# lts6_rpm_spec_epatch "${WORKDIR}/${PN}.spec" || die

	patchlist="cups-no-gzip-man.patch
cups-1.1.16-system-auth.patch
cups-multilib.patch
cups-serial.patch
cups-banners.patch
cups-serverbin-compat.patch
cups-no-export-ssllibs.patch
cups-str3448.patch
cups-direct-usb.patch
cups-lpr-help.patch
cups-peercred.patch
cups-pid.patch
cups-page-label.patch
cups-eggcups.patch
cups-getpass.patch
cups-driverd-timeout.patch
cups-strict-ppd-line-length.patch
cups-logrotate.patch
cups-usb-paperout.patch
cups-build.patch
cups-res_init.patch
cups-filter-debug.patch
cups-uri-compat.patch
cups-cups-get-classes.patch
cups-avahi.patch
cups-str3382.patch
cups-str3285_v2-str3503.patch
cups-str3390.patch
cups-str3391.patch
cups-str3381.patch
cups-str3399.patch
cups-str3403.patch
cups-str3407.patch
cups-str3418.patch
cups-CVE-2009-3553.patch
cups-str3422.patch
cups-str3413.patch
cups-str3439.patch
cups-str3440.patch
cups-str3442.patch
cups-negative-snmp-string-length.patch
cups-sidechannel-intrs.patch
cups-media-empty-warning.patch
cups-str3435.patch
cups-str3436.patch
cups-str3425.patch
cups-str3428.patch
cups-str3431.patch
cups-snmp-quirks.patch
cups-str3458.patch
cups-str3460.patch
cups-str3495.patch
cups-EAI_AGAIN.patch
cups-str3505.patch
cups-CVE-2010-0302.patch
cups-str3541.patch
cups-large-snmp-lengths.patch
cups-hp-deviceid-oid.patch
cups-texttops-rotate-page.patch
cups-cgi-vars.patch
cups-hostnamelookups.patch
cups-CVE-2010-0540.patch
cups-CVE-2010-0542.patch
cups-CVE-2010-1748.patch
cups-CVE-2010-2432.patch
cups-CVE-2010-2431.patch
cups-CVE-2010-2941.patch
cups-str3627.patch
cups-str3535.patch
cups-str3679.patch
cups-0755.patch
cups-undo-str2537.patch
cups-dns-failure-tolerance.patch
cups-snmp-conf-typo.patch
cups-str3795-str3880.patch"

	for patch in ${patchlist}; do
		epatch "${WORKDIR}/${patch}" || die
	done

	# create a missing symlink to allow https printing via IPP, bug #217293
	epatch "${FILESDIR}/${PN}-1.4.0-backend-https.patch"

	# CVE-2009-3553: Use-after-free (crash) due improper reference counting
	# in abstract file descriptors handling interface
	# upstream bug STR #3200
	#
	# Note: Provided by SRPM patches
	# epatch "${FILESDIR}/${PN}-1.4.2-str3200.patch"
}

src_configure() {
	# locale support
	strip-linguas ${LANGS}
	if [ -z "${LINGUAS}" ] ; then
		export LINGUAS=none
	fi

	local myconf
	if use ssl || use gnutls ; then
		myconf="${myconf} \
			$(use_enable gnutls) \
			$(use_enable !gnutls openssl)"
	else
		myconf="${myconf} \
			--disable-gnutls \
			--disable-openssl"
	fi

	econf \
		--libdir=/usr/$(get_libdir) \
		--localstatedir=/var \
		--with-cups-user=lp \
		--with-cups-group=lp \
		--with-docdir=/usr/share/cups/html \
		--with-languages="${LINGUAS}" \
		--with-pdftops=/usr/bin/pdftops \
		--with-system-groups=lpadmin \
		$(use_enable acl) \
		$(use_enable dbus) \
		$(use_enable debug) \
		$(use_enable debug debug-guards) \
		$(use_enable jpeg) \
		$(use_enable kerberos gssapi) \
		$(use_enable ldap) \
		$(use_enable pam) \
		$(use_enable png) \
		$(use_enable slp) \
		$(use_enable static) \
		$(use_enable tiff) \
		$(use_enable xinetd xinetd /etc/xinetd.d) \
		$(use_with java) \
		$(use_with perl) \
		$(use_with php) \
		$(use_with python) \
		--enable-libpaper \
		--enable-libusb \
		--enable-threads \
		--enable-pdftops \
		--disable-dnssd \
		${myconf}

	# install in /usr/libexec always, instead of using /usr/lib/cups, as that
	# makes more sense when facing multilib support.
	sed -i -e 's:SERVERBIN.*:SERVERBIN = "$(BUILDROOT)"/usr/libexec/cups:' Makedefs
	sed -i -e 's:#define CUPS_SERVERBIN.*:#define CUPS_SERVERBIN "/usr/libexec/cups":' config.h
	sed -i -e 's:cups_serverbin=.*:cups_serverbin=/usr/libexec/cups:' cups-config
}

src_install() {
	emake BUILDROOT="${D}" install || die "emake install failed"
	dodoc {CHANGES,CREDITS,README}.txt || die "dodoc install failed"

	# clean out cups init scripts
	rm -rf "${D}"/etc/{init.d/cups,rc*,pam.d/cups}

	# install our init script
	local neededservices
	use dbus && neededservices="$neededservices dbus"
	[[ -n ${neededservices} ]] && neededservices="need${neededservices}"
	sed -e "s/@neededservices@/$neededservices/" "${FILESDIR}"/cupsd.init.d > "${T}"/cupsd
	doinitd "${T}"/cupsd || die "doinitd failed"

	# install our pam script
	pamd_mimic_system cups auth account

	if use xinetd ; then
		# correct path
		sed -i -e "s:server = .*:server = /usr/libexec/cups/daemon/cups-lpd:" "${D}"/etc/xinetd.d/cups-lpd
		# it is safer to disable this by default, bug #137130
		grep -w 'disable' "${D}"/etc/xinetd.d/cups-lpd || \
			sed -i -e "s:}:\tdisable = yes\n}:" "${D}"/etc/xinetd.d/cups-lpd
	else
		rm -rf "${D}"/etc/xinetd.d
	fi

	keepdir /usr/libexec/cups/driver /usr/share/cups/{model,profiles} \
		/var/cache/cups /var/cache/cups/rss /var/log/cups /var/run/cups/certs \
		/var/spool/cups/tmp

	keepdir /etc/cups/{interfaces,ppd,ssl}

	use X || rm -r "${D}"/usr/share/applications

	# create /etc/cups/client.conf, bug #196967 and #266678
	echo "ServerName /var/run/cups/cups.sock" >> "${D}"/etc/cups/client.conf

	# Fix locale code for Norwegian (bug #520379).
	mv locale/cups_no.po locale/cups_nb.po
}

pkg_postinst() {
	echo
	elog "For information about installing a printer and general cups setup"
	elog "take a look at: http://www.gentoo.org/doc/en/printing-howto.xml"
	echo
}
