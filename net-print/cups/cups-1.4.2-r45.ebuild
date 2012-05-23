# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-print/cups/Attic/cups-1.4.2-r1.ebuild,v 1.5 2010/03/08 22:20:59 reavertm Exp $

EAPI="3"

inherit eutils flag-o-matic multilib pam versionator rpm lts6-rpm

MY_P=${P/_}

DESCRIPTION="The Common Unix Printing System."
HOMEPAGE="http://www.cups.org/"
SRPM="cups-1.4.2-44.el6_2.3.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~sparc-fbsd ~x86 ~x86-fbsd"
IUSE="acl dbus debug gnutls java +jpeg kerberos ldap pam perl php +png python samba slp +ssl static +tiff X xinetd"

COMMON_DEPEND="
	app-text/libpaper
	dev-libs/libgcrypt
	virtual/libusb
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
	X? ( x11-misc/xdg-utils )
"
PDEPEND="
	app-text/ghostscript-gpl[cups]
	>=app-text/poppler-0.12.3-r3[utils]
"

# upstream includes an interactive test which is a nono for gentoo.
# therefore, since the printing herd has bigger fish to fry, for now,
# we just leave it out, even if FEATURES=test
RESTRICT="${RESTRICT} test"

S="${WORKDIR}/${MY_P}"

LANGS="da de es eu fi fr it ja ko nl no pl pt pt_BR ru sv zh zh_TW"
for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

# Omit the cups-lspp.patch and the cups-serverbin-compat.patch.
# To Do: Revisit the possibility of including these patches.
SRPM_PATCHLIST="
Patch1: cups-no-gzip-man.patch
Patch2: cups-1.1.16-system-auth.patch
Patch3: cups-multilib.patch
Patch4: cups-serial.patch
Patch5: cups-banners.patch
Patch7: cups-no-export-ssllibs.patch
Patch8: cups-str3448.patch
Patch9: cups-direct-usb.patch
Patch10: cups-lpr-help.patch
Patch11: cups-peercred.patch
Patch12: cups-pid.patch
Patch13: cups-page-label.patch
Patch14: cups-eggcups.patch
Patch15: cups-getpass.patch
Patch16: cups-driverd-timeout.patch
Patch17: cups-strict-ppd-line-length.patch
Patch18: cups-logrotate.patch
Patch19: cups-usb-paperout.patch
Patch20: cups-build.patch
Patch21: cups-res_init.patch
Patch22: cups-filter-debug.patch
Patch23: cups-uri-compat.patch
Patch24: cups-cups-get-classes.patch
Patch25: cups-avahi.patch
Patch26: cups-str3382.patch
Patch27: cups-str3285_v2-str3503.patch
Patch28: cups-str3390.patch
Patch29: cups-str3391.patch
Patch30: cups-str3381.patch
Patch31: cups-str3399.patch
Patch32: cups-str3403.patch
Patch33: cups-str3407.patch
Patch34: cups-str3418.patch
Patch35: cups-CVE-2009-3553.patch
Patch36: cups-str3422.patch
Patch37: cups-str3413.patch
Patch38: cups-str3439.patch
Patch39: cups-str3440.patch
Patch40: cups-str3442.patch
Patch41: cups-negative-snmp-string-length.patch
Patch42: cups-sidechannel-intrs.patch
Patch43: cups-media-empty-warning.patch
Patch44: cups-str3435.patch
Patch45: cups-str3436.patch
Patch46: cups-str3425.patch
Patch47: cups-str3428.patch
Patch48: cups-str3431.patch
Patch49: cups-snmp-quirks.patch
Patch50: cups-str3458.patch
Patch51: cups-str3460.patch
Patch52: cups-str3495.patch
Patch54: cups-str3505.patch
Patch55: cups-CVE-2010-0302.patch
Patch56: cups-str3541.patch
Patch57: cups-large-snmp-lengths.patch
Patch58: cups-hp-deviceid-oid.patch
Patch59: cups-texttops-rotate-page.patch
Patch60: cups-cgi-vars.patch
Patch61: cups-hostnamelookups.patch
Patch62: cups-CVE-2010-0540.patch
Patch63: cups-CVE-2010-0542.patch
Patch64: cups-CVE-2010-1748.patch
Patch65: cups-CVE-2010-2432.patch
Patch66: cups-CVE-2010-2431.patch
Patch67: cups-CVE-2010-2941.patch
Patch68: cups-str3627.patch
Patch69: cups-str3535.patch
Patch70: cups-str3679.patch
Patch71: cups-0755.patch
Patch72: cups-undo-str2537.patch
Patch73: cups-dns-failure-tolerance.patch
Patch74: cups-snmp-conf-typo.patch
Patch75: cups-str3832.patch
Patch76: cups-str3861.patch
Patch77: cups-str3809.patch
Patch78: cups-str3867.patch
Patch79: cups-str3795-str3880.patch
Patch80: cups-handle-empty-files.patch
Patch81: cups-str4015.patch
Patch82: cups-str3449.patch
"

pkg_setup() {
	enewgroup lp
	enewuser lp -1 -1 -1 lp
	enewgroup lpadmin 106
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	lts6_srpm_epatch || die

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
