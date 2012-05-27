# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/ncurses/ncurses-5.7-r7.ebuild,v 1.9 2011/05/22 18:19:56 xarthisius Exp $

EAPI="1"
inherit eutils flag-o-matic toolchain-funcs rpm lts6-rpm

MY_PV=${PV:0:3}
PV_SNAP=${PV:4}
MY_P=${PN}-${MY_PV}
DESCRIPTION="console display library"
HOMEPAGE="http://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"

SRPM="ncurses-5.7-3.20090208.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="MIT"
SLOT="5"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~sparc-fbsd ~x86-fbsd"
IUSE="ada +cxx debug doc gpm minimal profile static-libs trace unicode"

DEPEND="gpm? ( sys-libs/gpm )"
#	berkdb? ( sys-libs/db )"
RDEPEND="${DEPEND}
	!<x11-terms/rxvt-unicode-9.06-r3"

S=${WORKDIR}/${MY_P}

SRPM_PATCHLIST="
# Patch 1 takes special handling
# Patch1: ncurses-5.7-20081115-20090207.patch.bz2
Patch8: ncurses-5.7-20090124-config.patch
Patch9: ncurses-5.6-20070612-libs.patch
# Use the urxvt patch provided with the Gentoo patch set.
# Patch11: ncurses-5.6-20080112-urxvt.patch
Patch12: ncurses-5.6-20080628-kbs.patch
"

src_unpack() {
	rpm_src_unpack || die
	cd "${S}"

	# This patch is very prickly to apply, and I had to fall
	# back to a more manual application method since it would
	# always fail the dry-run in epatch.
	#
	# This method was derived by examining the method used
	# when building this src.rpm package in an EL environment.
	einfo "Patching ncurses-5.7-20081115-20090207.patch.bz2..."
	bzip2 -dc "${WORKDIR}"/ncurses-5.7-20081115-20090207.patch.bz2 \
		| patch -p1 -s --fuzz=0 \
		|| die "Failed with EL Patch1"

	lts6_srpm_epatch || die

	[[ -n ${PV_SNAP} ]] && epatch "${WORKDIR}"/${MY_P}-${PV_SNAP}-patch.sh
	epatch "${FILESDIR}"/${PN}-5.6-gfbsd.patch
	# The emacs patch is covered by  
	# EL patch: ncurses-5.7-20081115-20090207.patch.bz2
	# epatch "${FILESDIR}"/${PN}-5.7-emacs.patch #270527
	epatch "${FILESDIR}"/${PN}-5.7-nongnu.patch
	epatch "${FILESDIR}"/${PN}-5.7-tic-cross-detection.patch #288881
	epatch "${FILESDIR}"/${PN}-5.7-rxvt-unicode-9.09.patch #192083
	# The hashdb-open patch is covered by
	# EL patch: ncurses-5.7-20081115-20090207.patch.bz2
	# epatch "${FILESDIR}"/${P}-hashdb-open.patch #245370

	sed -i '/with_no_leaks=yes/s:=.*:=$enableval:' configure #305889
}

src_compile() {
	unset TERMINFO #115036
	tc-export BUILD_CC
	export BUILD_CPPFLAGS+=" -D_GNU_SOURCE" #214642

	# when cross-compiling, we need to build up our own tic
	# because people often don't keep matching host/target
	# ncurses versions #249363
	if tc-is-cross-compiler && ! ROOT=/ has_version ~sys-libs/${P} ; then
		make_flags="-C progs tic"
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} -static" \
		do_compile cross --without-shared --with-normal
	fi

	make_flags=""
	do_compile narrowc
	use unicode && do_compile widec --enable-widec --includedir=/usr/include/ncursesw
}

do_compile() {
	ECONF_SOURCE=${S}

	mkdir "${WORKDIR}"/$1
	cd "${WORKDIR}"/$1
	shift

	# The chtype/mmask-t settings below are to retain ABI compat
	# with ncurses-5.4 so dont change em !
	local conf_abi="
		--with-chtype=long \
		--with-mmask-t=long \
		--disable-ext-colors \
		--disable-ext-mouse \
		--without-pthread \
		--without-reentrant \
	"
	# We need the basic terminfo files in /etc, bug #37026.  We will
	# add '--with-terminfo-dirs' and then populate /etc/terminfo in
	# src_install() ...
#		$(use_with berkdb hashed-db)
	econf \
		--with-terminfo-dirs="/etc/terminfo:/usr/share/terminfo" \
		--with-shared \
		--without-hashed-db \
		$(use_with ada) \
		$(use_with cxx) \
		$(use_with cxx cxx-binding) \
		$(use_with debug) \
		$(use_with profile) \
		$(use_with gpm) \
		--disable-termcap \
		--enable-symlinks \
		--with-rcs-ids \
		--with-manpage-format=normal \
		--enable-const \
		--enable-colorfgbg \
		--enable-echo \
		$(use_enable !ada warnings) \
		$(use_with debug assertions) \
		$(use_enable debug leaks) \
		$(use_with debug expanded) \
		$(use_with !debug macros) \
		$(use_with trace) \
		${conf_abi} \
		"$@"

	# A little hack to fix parallel builds ... they break when
	# generating sources so if we generate the sources first (in
	# non-parallel), we can then build the rest of the package
	# in parallel.  This is not really a perf hit since the source
	# generation is quite small.
	emake -j1 sources || die
	emake ${make_flags} || die
}

src_install() {
	# use the cross-compiled tic (if need be) #249363
	export PATH=${WORKDIR}/cross/progs:${PATH}

	# install unicode version second so that the binaries in /usr/bin
	# support both wide and narrow
	cd "${WORKDIR}"/narrowc
	emake DESTDIR="${D}" install || die
	if use unicode ; then
		cd "${WORKDIR}"/widec
		emake DESTDIR="${D}" install || die
	fi

	# Move libncurses{,w} into /lib
	gen_usr_ldscript -a ncurses
	use unicode && gen_usr_ldscript -a ncursesw
	ln -sf libncurses.so "${D}"/usr/$(get_libdir)/libcurses.so || die
	use static-libs || rm "${D}"/usr/$(get_libdir)/*.a

#	if ! use berkdb ; then
		# We need the basic terminfo files in /etc, bug #37026
		einfo "Installing basic terminfo files in /etc..."
		for x in ansi console dumb linux rxvt rxvt-unicode screen sun vt{52,100,102,200,220} \
				 xterm xterm-color xterm-xfree86
		do
			local termfile=$(find "${D}"/usr/share/terminfo/ -name "${x}" 2>/dev/null)
			local basedir=$(basename $(dirname "${termfile}"))

			if [[ -n ${termfile} ]] ; then
				dodir /etc/terminfo/${basedir}
				mv ${termfile} "${D}"/etc/terminfo/${basedir}/
				dosym ../../../../etc/terminfo/${basedir}/${x} \
					/usr/share/terminfo/${basedir}/${x}
			fi
		done

		# Build fails to create this ...
		dosym ../share/terminfo /usr/$(get_libdir)/terminfo
#	fi

	echo "CONFIG_PROTECT_MASK=\"/etc/terminfo\"" > "${T}"/50ncurses
	doenvd "${T}"/50ncurses

	use minimal && rm -r "${D}"/usr/share/terminfo*
	# Because ncurses5-config --terminfo returns the directory we keep it
	keepdir /usr/share/terminfo #245374

	cd "${S}"
	dodoc ANNOUNCE MANIFEST NEWS README* TO-DO doc/*.doc
	use doc && dohtml -r doc/html/
}