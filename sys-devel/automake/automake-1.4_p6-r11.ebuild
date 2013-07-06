# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/automake/automake-1.4_p6-r1.ebuild,v 1.9 2013/04/04 22:15:06 vapier Exp $

inherit eutils rpm lts6-rpm

MY_P="${P/_/-}"
DESCRIPTION="Used to generate Makefile.in from Makefile.am"
HOMEPAGE="http://www.gnu.org/software/automake/"
SRPM="automake14-1.4p6-19.2.el6.src.rpm"
SRC_URI="mirror://lts64/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="${PV:0:3}"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE=""

DEPEND="dev-lang/perl
	sys-devel/automake-wrapper
	>=sys-devel/autoconf-2.59-r6
	sys-devel/gnuconfig"
DEPEND="${RDEPEND}"

SRPM_PATCHLIST="
Patch1:     automake-1.4-libtoolize.patch
Patch2:     automake-1.4-subdir.patch
Patch3:     automake-1.4-backslash.patch
Patch6:     automake-1.4-tags.patch
Patch7:     automake-1.4-subdirs-89656.patch
# Patch8:     automake14-info.patch
Patch9:     automake-1.4-p6-CVE-2009-4029.patch
"

S=${WORKDIR}/${MY_P}

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"

	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-1.4-nls-nuisances.patch #121151
	# epatch "${FILESDIR}"/${PN}-1.4-libtoolize.patch
	# epatch "${FILESDIR}"/${PN}-1.4-subdirs-89656.patch
	epatch "${FILESDIR}"/${PN}-1.4-ansi2knr-stdlib.patch
	# epatch "${FILESDIR}"/${PN}-1.4-CVE-2009-4029.patch #295357
	sed -i 's:error\.test::' tests/Makefile.in #79529
	export WANT_AUTOCONF=2.5
}

# slot the info pages.  do this w/out munging the source so we don't have
# to depend on texinfo to regen things.  #464146 (among others)
slot_info_pages() {
	pushd "${D}"/usr/share/info >/dev/null
	rm -f dir

	# Rewrite all the references to other pages.
	# before: * aclocal-invocation: (automake)aclocal Invocation.   Generating aclocal.m4.
	# after:  * aclocal-invocation v1.13: (automake-1.13)aclocal Invocation.   Generating aclocal.m4.
	local p pages=( *.info ) args=()
	for p in "${pages[@]/%.info}" ; do
		args+=(
			-e "/START-INFO-DIR-ENTRY/,/END-INFO-DIR-ENTRY/s|: (${p})| v${SLOT}&|"
			-e "s:(${p}):(${p}-${SLOT}):g"
		)
	done
	sed -i "${args[@]}" * || die

	# Rewrite all the file references, and rename them in the process.
	local f d
	for f in * ; do
		d=${f/.info/-${SLOT}.info}
		mv "${f}" "${d}" || die
		sed -i -e "s:${f}:${d}:g" * || die
	done

	popd >/dev/null
}

src_install() {
	emake install DESTDIR="${D}" \
		pkgdatadir=/usr/share/automake-${SLOT} \
		m4datadir=/usr/share/aclocal-${SLOT} \
		|| die
	slot_info_pages
	rm -f "${D}"/usr/bin/{aclocal,automake}
	dosym automake-${SLOT} /usr/share/automake

	dodoc NEWS README THANKS TODO AUTHORS ChangeLog

	# remove all config.guess and config.sub files replacing them
	# w/a symlink to a specific gnuconfig version
	for x in guess sub ; do
		dosym ../gnuconfig/config.${x} /usr/share/${PN}-${SLOT}/config.${x}
	done
}
