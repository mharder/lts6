# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man/man-1.6f-r5.ebuild,v 1.2 2011/04/13 15:03:49 ulm Exp $

EAPI="4"

inherit eutils toolchain-funcs rpm lts6-rpm

DESCRIPTION="Standard commands to read man pages"
HOMEPAGE="http://primates.ximian.com/~flucifredi/man/"

SRPM="man-1.6f-30.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="+lzma nls"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="|| ( >=sys-apps/groff-1.19.2-r1 app-doc/heirloom-doctools )
	!sys-apps/man-db
	!app-arch/lzma
	lzma? ( app-arch/xz-utils )"

pkg_setup() {
	enewgroup man 15
	enewuser man 13 -1 /usr/share/man man
}

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	SRPM_PATCHLIST="
Patch1: man-1.5m2-confpath.patch
Patch2: man-1.5h1-make.patch
Patch6: man-1.5m2-apropos.patch
Patch10: man-1.6f-i18n_makewhatis.patch
Patch12: man-1.5m2-posix.patch
Patch18: man-1.6f-pipe_makewhatis.patch
Patch19: man-1.5p-sec.patch
Patch20: man-1.5p-xorg.patch
Patch21: man-1.6b-i18n_nroff.patch
Patch22: man-1.6b-man-pages.patch
Patch24: man-1.6c-disp.patch
Patch25: man-1.6f-dashes.patch
Patch26: man-1.6d-updates.patch
Patch27: man-1.6e-chmod.patch
Patch28: man-1.6f-i18n_makewhatis_2.patch
Patch29: man-1.6f-fr_translation.patch
Patch30: man-1.6f-loc.patch
Patch31: man-1.6f-tty.patch
Patch32: man-1.6f-dashes2.patch
Patch33: man-1.6f-star.patch
Patch34: man-1.6f-lang_C.patch
Patch35: man-1.6f-makewhatis_whis.patch
Patch36: man-1.6f-makewhatis_update.patch
Patch37: man-1.6f-makewhatis_perf.patch
Patch38: man-1.6f-makewhatis_use.patch
Patch39: man-1.6f-man2html-suffixes.patch
Patch40: man-1.6f-diff.patch
Patch41: man-1.6f-override_dir.patch
Patch42: man-1.6f-makewhatis_vari.patch
Patch43: man-1.6f-debuginfo.patch
Patch44: man-1.6f-jap.patch
Patch45: man-1.6f-symlinks.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/man-1.6f-man2html-compression-2.patch
	epatch "${FILESDIR}"/man-1.6-cross-compile.patch
	epatch "${FILESDIR}"/man-1.5p-search-order.patch
	# epatch "${FILESDIR}"/man-1.6f-unicode.patch #146315
	# epatch "${FILESDIR}"/man-1.5p-defmanpath-symlinks.patch
	epatch "${FILESDIR}"/man-1.6b-more-sections.patch
	epatch "${FILESDIR}"/man-1.6c-cut-duplicate-manpaths.patch
	# epatch "${FILESDIR}"/man-1.5m2-apropos.patch
	epatch "${FILESDIR}"/man-1.6d-fbsd.patch
	epatch "${FILESDIR}"/man-1.6e-headers.patch
	epatch "${FILESDIR}"/man-1.6f-so-search-2.patch
	epatch "${FILESDIR}"/man-1.6f-compress.patch
	epatch "${FILESDIR}"/man-1.6f-parallel-build-v2.patch #207148 #258916
	epatch "${FILESDIR}"/man-1.6f-xz-v2.patch #302380
	epatch "${FILESDIR}"/man-1.6f-makewhatis-compression-cleanup-v2.patch #331979
	# make sure `less` handles escape sequences #287183
	sed -i -e '/^DEFAULTLESSOPT=/s:"$:R":' configure

	find . -type f|xargs perl -pi -e 's,man\.conf \(5\),man.config (5),g'
	for i in $(find man -name man.conf.man); do
		mv $i ${i%man.conf.man}man.config.5
	done
}

echoit() { echo "$@" ; "$@" ; }
src_configure() {
	strip-linguas $(eval $(grep ^LANGUAGES= configure) ; echo ${LANGUAGES//,/ })

	unset NLSPATH #175258

	tc-export CC BUILD_CC

	local mylang=
	if use nls ; then
		if [[ -z ${LINGUAS} ]] ; then
			mylang="all"
		else
			mylang="${LINGUAS// /,}"
		fi
	else
		mylang="none"
	fi
	export COMPRESS
	if use lzma ; then
		COMPRESS=/usr/bin/xz
	else
		COMPRESS=/bin/bzip2
	fi
	echoit \
	./configure \
		-confdir=/etc \
		+sgid +fhs \
		+lang ${mylang} \
		|| die "configure failed"
}

src_install() {
	unset NLSPATH #175258

	emake PREFIX="${D}" install || die "make install failed"
	dosym man /usr/bin/manpath

	dodoc LSM README* TODO

	# makewhatis only adds man-pages from the last 24hrs
	exeinto /etc/cron.daily
	newexe "${FILESDIR}"/makewhatis.cron makewhatis

	keepdir /var/cache/man
	diropts -m0775 -g man
	local mansects=$(grep ^MANSECT "${D}"/etc/man.conf | cut -f2-)
	for x in ${mansects//:/ } ; do
		keepdir /var/cache/man/cat${x}
	done
}

pkg_postinst() {
	einfo "Forcing sane permissions onto ${ROOT}var/cache/man (Bug #40322)"
	chown -R root:man "${ROOT}"/var/cache/man
	chmod -R g+w "${ROOT}"/var/cache/man
	[[ -e ${ROOT}/var/cache/man/whatis ]] \
		&& chown root:0 "${ROOT}"/var/cache/man/whatis

	echo

	local f files=$(ls "${ROOT}"/etc/cron.{daily,weekly}/makewhatis{,.cron} 2>/dev/null)
	for f in ${files} ; do
		[[ ${f} == */etc/cron.daily/makewhatis ]] && continue
		[[ $(md5sum "${f}") == "8b2016cc778ed4e2570b912c0f420266 "* ]] \
			&& rm -f "${f}"
	done
	files=$(ls "${ROOT}"etc/cron.{daily,weekly}/makewhatis{,.cron} 2>/dev/null)
	if [[ ${files/$'\n'} != ${files} ]] ; then
		ewarn "You have multiple makewhatis cron files installed."
		ewarn "You might want to delete all but one of these:"
		ewarn ${files}
	fi

	if has_version app-doc/heirloom-doctools; then
		ewarn "Please note that the /etc/man.conf file installed will not"
		ewarn "work with heirloom's nroff by default (yet)."
		ewarn ""
		ewarn "Check app-doc/heirloom-doctools elog messages for the proper"
		ewarn "configuration."
	fi
}
