# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openssh/Attic/openssh-5.3_p1-r1.ebuild,v 1.10 2010/03/20 00:17:55 vapier Exp $

EAPI="3"

inherit eutils flag-o-matic multilib autotools pam rpm lts6-rpm

# Make it more portable between straight releases
# and _p? releases.
PARCH=${P/_/}

# HPN_PATCH="${PARCH}-hpn13v6-gentoo.diff.gz"
# LDAP_PATCH="${PARCH/openssh/openssh-lpk}-0.3.11.patch.gz"
# PKCS11_PATCH="${PARCH/3p1/2}pkcs11-0.26.tar.bz2"
# X509_VER="6.2.1" X509_PATCH="${PARCH}+x509-${X509_VER}.diff.gz"

DESCRIPTION="Port of OpenBSD's free SSH release"
HOMEPAGE="http://www.openssh.org/"
# Remove hpn patch since it's not currently available.
#	${HPN_PATCH:+hpn? ( http://www.psc.edu/networking/projects/hpn-ssh/${HPN_PATCH} )}
#
# Remove ldap patch.  SRPM has patches for ldap, this patch isn't available,
#                     and may no longer be maintainted.
#	${LDAP_PATCH:+ldap? ( mirror://gentoo/${LDAP_PATCH} )}
# 
# Remove pkcs11 patch. This adds a capability whose level of maintenance
#                      isn't currently known.
#	${PKCS11_PATCH:+pkcs11? ( http://alon.barlev.googlepages.com/${PKCS11_PATCH} )}
#
# Remove x509 patch. Same issues as above for now.
#	${X509_PATCH:+X509? ( http://roumenpetrov.info/openssh/x509-${X509_VER}/${X509_PATCH} )}"

# SRC_URI="mirror://openbsd/OpenSSH/portable/${PARCH}.tar.gz"
pam_ssh_agent_ver="0.9"
SRPM="openssh-5.3p1-70.el6_2.2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	http://prdownloads.sourceforge.net/pamsshagentauth/pam_ssh_agent_auth/pam_ssh_agent_auth-${pam_ssh_agent_ver}.tar.bz2"
RESTRICT="mirror"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
# Remove hpn from IUSE since the patch isn't currently available.
# Remove X509, electing to not implement in SRPM version for time being.
IUSE="elfips kerberos ldap libedit pam selinux skey smartcard static tcpd X"

RDEPEND="pam? ( virtual/pam )
	kerberos? ( virtual/krb5 )
	selinux? ( >=sys-libs/libselinux-1.28 )
	skey? ( >=sys-auth/skey-1.1.5-r1 )
	ldap? ( net-nds/openldap )
	libedit? ( dev-libs/libedit )
	>=dev-libs/openssl-0.9.6d[elfips?]
	>=sys-libs/zlib-1.2.3
	smartcard? ( dev-libs/opensc )
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )
	X? ( x11-apps/xauth )
	userland_GNU? ( sys-apps/shadow )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	virtual/os-headers
	sys-devel/autoconf"
RDEPEND="${RDEPEND}
	pam? ( >=sys-auth/pambase-20081028 )"
PROVIDE="virtual/ssh"

S=${WORKDIR}/${PARCH}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	cd "${S}"

	# Common SRPM Patches
	SRPM_PATCHLIST="Patch0: openssh-5.2p1-redhat.patch
			Patch2: openssh-5.3p1-skip-initial.patch
			Patch4: openssh-5.2p1-vendor.patch
			Patch5: openssh-5.3p1-engine.patch"
	lts6_srpm_epatch || die

	if use pam ; then
		cp -a "${WORKDIR}/pam_ssh_agent_auth-${pam_ssh_agent_ver}" \
			"${S}"
		cd "${S}/pam_ssh_agent_auth-${pam_ssh_agent_ver}"
		SRPM_PATCHLIST="Patch10: pam_ssh_agent_auth-0.9-build.patch
			Patch11: pam_ssh_agent_auth-0.9.2-seteuid.patch"
		lts6_srpm_epatch || die
		cd "${S}"
	fi

	if use selinux ; then
		# SRPM selinux patches
		SRPM_PATCHLIST="Patch12: openssh-5.2p1-selinux.patch
				Patch13: openssh-5.3p1-mls.patch
				Patch18: openssh-5.0p1-pam_selinux.patch
				Patch19: openssh-5.3p1-sesftp.patch"
		lts6_srpm_epatch || die
	fi

	SRPM_PATCHLIST="Patch22: openssh-3.9p1-askpass-keep-above.patch
			Patch24: openssh-4.3p1-fromto-remote.patch
			Patch27: openssh-5.1p1-log-in-chroot.patch
			Patch30: openssh-4.0p1-exit-deadlock.patch
			Patch35: openssh-5.1p1-askpass-progress.patch
			Patch38: openssh-4.3p2-askpass-grab-info.patch
			Patch39: openssh-4.3p2-no-v6only.patch
			Patch44: openssh-5.2p1-allow-ip-opts.patch
			Patch49: openssh-4.3p2-gssapi-canohost.patch
			Patch51: openssh-5.3p1-nss-keys.patch
			Patch55: openssh-5.1p1-cloexec.patch
			Patch62: openssh-5.1p1-scp-manpage.patch"

	lts6_srpm_epatch || die

	if use elfips ; then
		SRPM_PATCHLIST="Patch65: openssh-5.3p1-fips.patch"
		lts6_srpm_epatch || die
	fi

	if use selinux ; then
		SRPM_PATCHLIST="Patch69: openssh-5.3p1-selabel.patch"
		lts6_srpm_epatch || die
	fi

        SRPM_PATCHLIST="Patch71: openssh-5.2p1-edns.patch
			Patch73: openssh-5.3p1-gsskex.patch
			Patch74: openssh-5.3p1-randclean.patch
			Patch75: openssh-5.3p1-strictalias.patch
			Patch76: openssh-5.3p1-595935.patch
			Patch77: openssh-5.3p1-x11.patch
			Patch78: openssh-5.3p1-authorized-keys-command.patch
			Patch79: openssh-5.3p1-stderr.patch"

	lts6_srpm_epatch || die

	if use selinux ; then
		SRPM_PATCHLIST="Patch80: openssh-5.3p1-audit.patch"
		lts6_srpm_epatch || die
	fi
			
	SRPM_PATCHLIST="Patch81: openssh-5.3p1-biguid.patch
			Patch82: openssh-5.3p1-kuserok.patch
			Patch83: openssh-5.3p1-sftp_umask.patch
			Patch84: openssh-5.3p1-clientloop.patch"

	lts6_srpm_epatch || die

	if use ldap ; then
		SRPM_PATCHLIST="Patch85: openssh-5.3p1-ldap.patch"
		lts6_srpm_epatch || die
	fi

	# Make the keycat patch depend on SELinux
	# It shouldn't be mandatory, but the patch seems set
	# up that way.
	if use selinux ; then
		SRPM_PATCHLIST="Patch86: openssh-5.3p1-keycat.patch
				Patch87: openssh-5.3p1-sftp-chroot.patch"
		lts6_srpm_epatch || die
	fi

	# It almost looks like these patches rely on the previous
	# ldap patch.  Need to test that...
	SRPM_PATCHLIST="Patch88: openssh-5.3p1-entropy.patch
			Patch89: openssh-5.3p1-multiple-sighup.patch
			Patch90: openssh-5.3p1-ipv6man.patch
			Patch91: openssh-5.3p1-manerr.patch
			Patch92: openssh-5.3p1-askpass-ld.patch
			Patch93: openssh-5.3p1-ctr-evp-fast.patch"
	lts6_srpm_epatch || die

	sed -i \
		-e '/_PATH_XAUTH/s:/usr/X11R6/bin/xauth:/usr/bin/xauth:' \
		pathnames.h || die

	use smartcard && epatch "${FILESDIR}"/openssh-3.9_p1-opensc.patch
	# use ldap && epatch "${FILESDIR}"/${PN}-5.2p1-ldap-stdargs.diff #266654

	# Already Provide by SRPM patches.
	# epatch "${FILESDIR}"/${PN}-4.7_p1-GSSAPI-dns.patch #165444 integrated into gsskex

	# Comment out hpn patch until source is located.
	# [[ -n ${HPN_PATCH} ]] && use hpn && epatch "${DISTDIR}"/${HPN_PATCH}
	epatch "${FILESDIR}"/${PN}-4.7p1-selinux.diff #191665
	epatch "${FILESDIR}"/${PN}-5.2_p1-autoconf.patch

	# in 5.2p1, the AES-CTR multithreaded variant is temporarily broken, and
	# causes random hangs when combined with the -f switch of ssh.
	# To avoid this, we change the internal table to use the non-multithread
	# version for the meantime.
	sed -i \
		-e '/aes...-ctr.*SSH_CIPHER_SSH2/s,evp_aes_ctr_mt,evp_aes_128_ctr,' \
		cipher.c || die

	sed -i "s:-lcrypto:$(pkg-config --libs openssl):" configure{,.ac} || die

	# Disable PATH reset, trust what portage gives us. bug 254615
	sed -i -e 's:^PATH=/:#PATH=/:' configure || die

	eautoreconf
}

static_use_with() {
	local flag=$1
	if use static && use ${flag} ; then
		ewarn "Disabling '${flag}' support because of USE='static'"
		# rebuild args so that we invert the first one (USE flag)
		# but otherwise leave everything else working so we can
		# just leverage use_with
		shift
		[[ -z $1 ]] && flag="${flag} ${flag}"
		set -- !${flag} "$@"
	fi
	use_with "$@"
}

src_compile() {
	addwrite /dev/ptmx
	addpredict /etc/skey/skeykeys #skey configure code triggers this

	local myconf=""
	use static && append-ldflags -static

	econf \
		--with-ldflags="${LDFLAGS}" \
		--disable-strip \
		--sysconfdir=/etc/ssh \
		--libexecdir=/usr/$(get_libdir)/misc \
		--datadir=/usr/share/openssh \
		--with-privsep-path=/var/empty \
		--with-privsep-user=sshd \
		--with-md5-passwords \
		--with-ssl-engine \
		$(static_use_with pam) \
		$(static_use_with kerberos kerberos5 /usr) \
		$(use_with ldap) \
		$(use_with libedit) \
		$(use_with selinux) \
		$(use_with skey) \
		$(use_with smartcard opensc) \
		$(use_with tcpd tcp-wrappers) \
		${myconf} \
		|| die "bad configure"
	emake || die "compile problem"
}

src_install() {
	emake install-nokeys DESTDIR="${D}" || die
	fperms 600 /etc/ssh/sshd_config
	dobin contrib/ssh-copy-id
	newinitd "${FILESDIR}"/sshd.rc6 sshd
	newconfd "${FILESDIR}"/sshd.confd sshd
	keepdir /var/empty

	newpamd "${FILESDIR}"/sshd.pam_include.2 sshd
	if use pam ; then
		sed -i \
			-e "/^#UsePAM /s:.*:UsePAM yes:" \
			-e "/^#PasswordAuthentication /s:.*:PasswordAuthentication no:" \
			-e "/^#PrintMotd /s:.*:PrintMotd no:" \
			-e "/^#PrintLastLog /s:.*:PrintLastLog no:" \
			"${D}"/etc/ssh/sshd_config || die "sed of configuration file failed"
	fi

	# Comment out hpn patch stuff until source is located.

	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	# if [[ -n ${HPN_PATCH} ]] && use hpn; then
	#	keepdir /var/empty/dev
	# fi

	doman contrib/ssh-copy-id.1
	dodoc ChangeLog CREDITS OVERVIEW README* TODO sshd_config

	diropts -m 0700
	dodir /etc/skel/.ssh
}

src_test() {
	local t tests skipped failed passed shell
	tests="interop-tests compat-tests"
	skipped=""
	shell=$(getent passwd ${UID} | cut -d: -f7)
	if [[ ${shell} == */nologin ]] || [[ ${shell} == */false ]] ; then
		elog "Running the full OpenSSH testsuite"
		elog "requires a usable shell for the 'portage'"
		elog "user, so we will run a subset only."
		skipped="${skipped} tests"
	else
		tests="${tests} tests"
	fi
	for t in ${tests} ; do
		# Some tests read from stdin ...
		emake -k -j1 ${t} </dev/null \
			&& passed="${passed}${t} " \
			|| failed="${failed}${t} "
	done
	einfo "Passed tests: ${passed}"
	ewarn "Skipped tests: ${skipped}"
	if [[ -n ${failed} ]] ; then
		ewarn "Failed tests: ${failed}"
		die "Some tests failed: ${failed}"
	else
		einfo "Failed tests: ${failed}"
		return 0
	fi
}

pkg_postinst() {
	enewgroup sshd 22
	enewuser sshd 22 -1 /var/empty sshd

	# help fix broken perms caused by older ebuilds.
	# can probably cut this after the next stage release.
	chmod u+x "${ROOT}"/etc/skel/.ssh >& /dev/null

	ewarn "Remember to merge your config files in /etc/ssh/ and then"
	ewarn "reload sshd: '/etc/init.d/sshd reload'."
	if use pam ; then
		echo
		ewarn "Please be aware users need a valid shell in /etc/passwd"
		ewarn "in order to be allowed to login."
	fi

	# Comment out hpn stuff until source is located.

	# This instruction is from the HPN webpage,
	# Used for the server logging functionality
	# if [[ -n ${HPN_PATCH} ]] && use hpn; then
	#	echo
	#	einfo "For the HPN server logging patch, you must ensure that"
	#	einfo "your syslog application also listens at /var/empty/dev/log."
	# fi
}
