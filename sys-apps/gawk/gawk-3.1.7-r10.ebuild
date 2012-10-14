# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.8.ebuild,v 1.7 2011/08/05 19:08:07 jer Exp $

EAPI="4"

inherit eutils toolchain-funcs multilib rpm lts6-rpm

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRPM="gawk-3.1.7-10.el6.src.rpm"
SRC_URI="mirror://lts63/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="nls"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SFFS=${WORKDIR}/filefuncs

src_unpack() {
	rpm_src_unpack || die

	# The rpm eclass doesn't support .xz archives yet.
	unpack "./${P}.tar.xz" || die

	# Copy filefuncs module's source over ...
	cp -r "${FILESDIR}"/filefuncs "${SFFS}" || die "cp failed"
}

src_prepare() {
	SRPM_PATCHLIST="Patch0: gawk-3.1.7-prec-utf8.patch
			Patch1: gawk-3.1.7-max-int.patch
			Patch2: gawk-3.1.7-syntax.patch
			Patch3: gawk-3.1.7-double-free-wstptr.patch
			Patch4: gawk-3.1.7-byacc-overflow.patch
			Patch5: gawk-3.1.7-preserve-argv.patch
			Patch6: gawk-3.1.7-signed-overflow-warning.patch
			Patch7: gawk-3.1.7-mbgsub.patch"
	lts6_srpm_epatch || die

	epatch "${FILESDIR}"/${PN}-3.1.6-gnuinfo.patch #249130

	# use symlinks rather than hardlinks, and disable version links
	sed -i \
		-e '/^LN =/s:=.*:= $(LN_S):' \
		-e '/install-exec-hook:/s|$|\nfoo:|' \
		Makefile.in doc/Makefile.in
}

src_configure() {
	export ac_cv_libsigsegv=no
	econf \
		--libexec='$(libdir)/misc' \
		$(use_enable nls) \
		--enable-switch \
		--disable-libsigsegv
}

src_compile() {
	emake || die
	emake -C "${SFFS}" CC="$(tc-getCC)" || die "filefuncs emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	emake -C "${SFFS}" LIBDIR="$(get_libdir)" install || die

	# Keep important gawk in /bin
	if use userland_GNU ; then
		dodir /bin
		mv "${D}"/usr/bin/gawk "${D}"/bin/ || die
		dosym /bin/gawk /usr/bin/gawk

		# Provide canonical `awk`
		dosym gawk /bin/awk
		dosym gawk /usr/bin/awk
		dosym gawk.1 /usr/share/man/man1/awk.1
	fi

	# Install headers
	insinto /usr/include/awk
	doins *.h || die
	# We do not want 'acconfig.h' in there ...
	rm -f "${D}"/usr/include/awk/acconfig.h

	dodoc AUTHORS ChangeLog FUTURES LIMITATIONS NEWS PROBLEMS POSIX.STD README README_d/*.*
	for x in */ChangeLog ; do
		newdoc ${x} ${x##*/}.${x%%/*}
	done
}
