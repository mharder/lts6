# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/curl/Attic/curl-7.19.7.ebuild,v 1.3 2010/07/01 20:14:54 spatz dead $

EAPI="4"

inherit autotools multilib eutils rpm lts6-rpm

DESCRIPTION="A Client that groks URLs"
HOMEPAGE="http://curl.haxx.se/"

SRPM="curl-7.19.7-26.el6_2.4.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="ares gnutls idn ipv6 kerberos ldap nss ssh ssl static-libs test"

RDEPEND="gnutls? ( net-libs/gnutls app-misc/ca-certificates )
	nss? ( !gnutls? ( dev-libs/nss app-misc/ca-certificates ) )
	ssl? ( !gnutls? ( !nss? ( dev-libs/openssl app-misc/ca-certificates ) ) )
	ldap? ( net-nds/openldap )
	idn? ( net-dns/libidn )
	ares? ( >=net-dns/c-ares-1.4.0 )
	kerberos? ( virtual/krb5 )
	ssh? ( >=net-libs/libssh2-0.16 )"

# fbopenssl (not in gentoo) --with-spnego
# krb4 http://web.mit.edu/kerberos/www/krb4-end-of-life.html

DEPEND="${RDEPEND}
	test? (
		sys-apps/diffutils
		dev-lang/perl
	)"
# used - but can do without in self test: net-misc/stunnel

src_unpack() {
	# Explicit support for lzma archives required.
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	unpack "./${P}.tar.lzma" || die
}

src_prepare() {
	SRPM_PATCHLIST="# upstream patches (already applied)
		Patch1: curl-7.19.7-modelfree.patch
		Patch2: curl-7.19.7-ssl-retry.patch
		Patch3: curl-7.19.7-nss-warning.patch
		Patch5: curl-7.19.7-socks-man.patch
		Patch6: curl-7.19.7-dns-timeout.patch
		Patch7: curl-7.20.0-read.patch
		# other patches
		Patch4: curl-7.19.7-ssl-timeout.patch
		# bz #565972
		Patch8: curl-7.20.0-cc-err.patch
		# bz #579732
		Patch9: curl-7.20.0-bz579732.patch
		# Fedora patches
		Patch101: curl-7.15.3-multilib.patch
		Patch102: curl-7.16.0-privlibs.patch
		Patch103: curl-7.19.4-debug.patch
		# http://curl.haxx.se/mail/lib-2009-12/0031.html
		Patch104: curl-7.19.7-s390-sleep.patch
		# we have localhost6 instead of ip6-localhost as name for ::1
		Patch105: curl-7.19.7-localhost6.patch
		Patch201: curl-7.19.7-bz563220.patch"
	lts6_srpm_epatch || die

	# bz #581485
	# Patch10: curl-7.20.1-crl.patch
	einfo "Applying curl-7.20.1-crl.patch..."
	cat "${WORKDIR}/curl-7.20.1-crl.patch" | patch -p1

	SRPM_PATCHLIST="Patch11: curl-7.19.7-bz586355.patch
		Patch12: curl-7.19.7-bz589132.patch
		# bz #606819
		Patch13: curl-7.21.0-ntlm.patch
		Patch202: curl-7.19.7-bz623663.patch
		Patch203: curl-7.19.7-bz655134.patch
		Patch204: curl-7.19.7-bz625685.patch
		Patch205: curl-7.19.7-bz651592.patch"
	lts6_srpm_epatch || die

	# This patch fails the dry-run, but applies if dry-run is skipped.
	# Patch206: curl-7.19.7-bz669702.patch
	einfo "Applying curl-7.19.7-bz669702.patch..."
	cat "${WORKDIR}/curl-7.19.7-bz669702.patch" | patch -p1

	SRPM_PATCHLIST="Patch207: curl-7.19.7-bz670802.patch
		Patch208: curl-7.19.7-bz678594.patch
		Patch209: curl-7.19.7-bz678580.patch
		Patch210: curl-7.19.7-bz684892.patch
		Patch211: curl-7.19.7-bz694294.patch
		# CVE-2011-2192
		Patch212: curl-7.19.7-bz711454.patch"
	lts6_srpm_epatch || die

	# This patch fails the dry-run, but applies if dry-run is skipped.
	# Patch213: curl-7.19.7-bz719938.patch
	einfo "Applying curl-7.19.7-bz719938.patch..."
	cat "${WORKDIR}/curl-7.19.7-bz719938.patch" | patch -p1

	SRPM_PATCHLIST="Patch214: curl-7.19.7-bz772642.patch
		Patch215: curl-7.19.7-bz738456.patch"
	lts6_srpm_epatch || die

	# Overridden by curl-7.15.3-multilib.patch
	# epatch "${FILESDIR}"/curl-7.17.0-strip-ldflags.patch

	# Accept modifications provided by EL patch
	# curl-7.15.3-multilib.patch instead.
	# epatch "${FILESDIR}"/curl-7.19.7-test241.patch

	eautoreconf
}

src_configure() {
	myconf="$(use_enable ldap)
		$(use_enable ldap ldaps)
		$(use_with idn libidn)
		$(use_with kerberos gssapi /usr)
		$(use_with ssh libssh2)
		$(use_enable static-libs static)
		$(use_enable ipv6)
		$(use_enable ares)
		--enable-http
		--enable-ftp
		--enable-gopher
		--enable-file
		--enable-dict
		--enable-manual
		--enable-telnet
		--enable-nonblocking
		--enable-largefile
		--enable-maintainer-mode
		--disable-sspi
		--without-krb4
		--without-spnego"

	if use gnutls; then
		myconf="${myconf} --without-ssl --with-gnutls --without-nss"
		myconf="${myconf} --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
	elif use nss; then
		myconf="${myconf} --without-ssl --without-gnutls --with-nss"
		myconf="${myconf} --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt"
	elif use openssl; then
		myconf="${myconf} --without-gnutls --without-nss --with-ssl"
		myconf="${myconf} --without-ca-bundle --with-ca-path=/etc/ssl/certs"
	else
		myconf="${myconf} --without-gnutls --without-nss --without-ssl"
	fi

	econf ${myconf} || die 'configure failed'
}

src_install() {
	emake DESTDIR="${ED}" install || die "installed failed for current version"
	find "${ED}" -name '*.la' -delete
	rm -rf "${ED}"/etc/

	# https://sourceforge.net/tracker/index.php?func=detail&aid=1705197&group_id=976&atid=350976
	insinto /usr/share/aclocal
	doins docs/libcurl/libcurl.m4

	dodoc CHANGES README
	dodoc docs/FEATURES docs/INTERNALS
	dodoc docs/MANUAL docs/FAQ docs/BUGS docs/CONTRIBUTE
}
