# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/xulrunner/xulrunner-2.0.1-r1.ebuild,v 1.11 2012/05/05 02:54:23 jdhore Exp $

EAPI="3"
WANT_AUTOCONF="2.1"

inherit flag-o-matic toolchain-funcs eutils mozconfig-3 makeedit multilib
inherit autotools python versionator pax-utils prefix rpm lts6-rpm

# MAJ_XUL_PV="$(get_version_component_range 1-2)" # from mozilla-* branch name
MAJ_XUL_PV="$(get_version_component_range 1)" # from mozilla-* branch name
# MAJ_FF_PV="10"
# FF_PV="${PV/${MAJ_XUL_PV}/${MAJ_FF_PV}}" # 3.7_alpha6, 3.6.3, etc.
# FF_PV="${FF_PV/_alpha/a}" # Handle alpha for SRC_URI
# FF_PV="${FF_PV/_beta/b}" # Handle beta for SRC_URI
# FF_PV="${FF_PV/_rc/rc}" # Handle rc for SRC_URI

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
HOMEPAGE="http://developer.mozilla.org/en/docs/XULRunner"

KEYWORDS="~amd64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
SLOT="1.9"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
IUSE="+crashreporter gconf +ipc system-sqlite +webm"

SRPM="xulrunner-10.0.4-1.el6_2.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

ASM_DEPEND=">=dev-lang/yasm-1.1.0"

RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.13.1
	>=dev-libs/nspr-4.8.9
	>=dev-libs/glib-2.26
	gconf? ( >=gnome-base/gconf-1.2.1:2 )
	media-libs/libpng[apng]
	virtual/libffi
	system-sqlite? ( >=dev-db/sqlite-3.7.4[fts3,secure-delete,unlock-notify,debug=] )
	webm? ( media-libs/libvpx
		media-libs/alsa-lib
		media-libs/mesa )"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	webm? ( amd64? ( ${ASM_DEPEND} )
		x86? ( ${ASM_DEPEND} ) )"

S="${WORKDIR}/mozilla-esr${MAJ_XUL_PV}"

SRPM_PATCHLIST="
# Firefox patches
# Build patches
#
# Skip Patch0, it depends on building in an RPM environment.
# Patch0:         xulrunner-version.patch

# Needed for second arches
# Patch10:        xulrunner-gc-sections-ppc.patch
# Patch15:        mozilla-691898.patch

# Xulrunner patches
Patch1:         mozilla-build.patch
Patch16:        xulrunner-2.0-chromium-types.patch
Patch17:        camelia.patch

Patch24:        mozilla-abort.patch

# RHEL specific patches
Patch50:        add-gtkmozembed-10.0.patch
Patch51:        mozilla-193-pkgconfig.patch
# Solves runtime crash of yelp:
Patch53:        mozilla-720682-jemalloc-missing.patch
# Fix key generation in software crypto tokens
Patch54:        xulrunner-crypto-token.patch

# RHEL6 specific patches
Patch100:       mozilla-gcc-4.4.patch

# RHEL5 specific patches
# Xulrunner patches
# Patch200:       mozilla-python.patch
# Patch201:       rhbz-729632.patch

# Upstream patches
Patch401:       mozilla-746112.patch
"

pkg_setup() {
	moz_pkgsetup
}

src_prepare() {
	lts6_srpm_epatch || die

	if use ppc || use ppc64 ; then
		SRPM_PATCHLIST="Patch10:        xulrunner-gc-sections-ppc.patch"
		lts6_srpm_epatch || die
	fi

	# Allow for either vpx-0.9.7 or vpx 1.0.0
	epatch "${FILESDIR}/xulrunner-10.0.4-vpx.patch" || die

	# Allow user to apply any additional patches without modifing ebuild
	epatch_user

	eprefixify \
		xpcom/build/nsXPCOMPrivate.h \
		xulrunner/installer/Makefile.in
	#	extensions/java/xpcom/interfaces/org/mozilla/xpcom/Mozilla.java \
	#	xulrunner/app/nsRegisterGREUnix.cpp

	# fix double symbols due to double -ljemalloc
	sed -i -e '/^LIBS += $(JEMALLOC_LIBS)/s/^/#/' \
		xulrunner/stub/Makefile.in || die

	#Fix compilation with curl-7.21.7 bug 376027
	sed -e '/#include <curl\/types\.h>/d' \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/libcurl_wrapper.cc \
		-i "${S}"/toolkit/crashreporter/google-breakpad/src/common/linux/http_upload.cc \
			|| die
	sed -e '/curl\/types\.h/d' \
		-i "${S}"/config/system-headers \
		-i "${S}"/js/src/config/system-headers \
			|| die

	# Same as in config/autoconf.mk.in
	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_XUL_PV}/sdk"

	# Gentoo install dirs
	sed -i -e "s:@PV@:${MAJ_XUL_PV}:" "${S}"/config/autoconf.mk.in \
		|| die "${MAJ_XUL_PV} sed failed!"

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Disable gnomevfs extension
	sed -i -e "s:gnomevfs::" "${S}/"xulrunner/confvars.sh \
		|| die "Failed to remove gnomevfs extension"

	eautoreconf

	cd js/src
	eautoreconf
}

src_configure() {
	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	mozconfig_config

	MEXTENSIONS="default"

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	mozconfig_annotate '' --with-default-mozilla-five-home="${MOZLIBDIR}"
	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"
	mozconfig_annotate '' --disable-mailnews
	mozconfig_annotate '' --enable-canvas
	mozconfig_annotate '' --enable-safe-browsing
	mozconfig_annotate '' --with-system-png
	mozconfig_annotate '' --enable-system-ffi
	mozconfig_use_enable system-sqlite
	mozconfig_use_enable gconf

	# Finalize and report settings
	mozconfig_final

	if [[ $(gcc-major-version) -lt 4 ]]; then
		append-flags -fno-stack-protector
	fi

	# Ensure we do not fail on i{3,5,7} processors that support -mavx
	if use amd64 || use x86; then
		append-flags -mno-avx
	fi

	####################################
	#
	#  Configure and build
	#
	####################################

	# Disable no-print-directory
	MAKEOPTS=${MAKEOPTS/--no-print-directory/}

	# Ensure that are plugins dir is enabled as default
	sed -i -e "s:/usr/lib/mozilla/plugins:/usr/$(get_libdir)/nsbrowser/plugins:" \
		"${S}"/xpcom/io/nsAppFileLocationProvider.cpp || die "sed failed to replace plugin path!"

	# hack added to workaround bug 299905 on hosts with libc that doesn't
	# support tls, (probably will only hit this condition with Gentoo Prefix)
	tc-has-tls -l || export ac_cv_thread_keyword=no

	CC="$(tc-getCC)" CXX="$(tc-getCXX)" LD="$(tc-getLD)" PYTHON="$(PYTHON)" econf
}

src_install() {
	# Add our defaults to xulrunner and out of firefox
	# cp "${FILESDIR}"/xulrunner-default-prefs.js \
	#	"${S}/dist/bin/defaults/pref/all-gentoo.js" || \
	#		die "failed to cp xulrunner-default-prefs.js"

	emake DESTDIR="${D}" install || die "emake install failed"

	rm "${ED}"/usr/bin/xulrunner

	MOZLIBDIR="/usr/$(get_libdir)/${PN}-${MAJ_XUL_PV}"
	SDKDIR="/usr/$(get_libdir)/${PN}-devel-${MAJ_XUL_PV}/sdk"

	if has_multilib_profile; then
		local config
		for config in "${ED}"/etc/gre.d/*.system.conf ; do
			mv "${config}" "${config%.conf}.${CHOST}.conf"
		done
	fi

	dodir /usr/bin
	dosym "${MOZLIBDIR}/xulrunner" "/usr/bin/xulrunner-${MAJ_XUL_PV}" || die

	# env.d file for ld search path
	dodir /etc/env.d
	echo "LDPATH=${EPREFIX}/${MOZLIBDIR}" > "${ED}"/etc/env.d/08xulrunner || die "env.d failed"

	pax-mark m "${ED}"/${MOZLIBDIR}/plugin-container
}
