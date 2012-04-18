# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/freetype/Attic/freetype-2.3.11.ebuild,v 1.6 2010/05/20 00:39:15 jer Exp $

EAPI="4"

inherit autotools autotools-utils eutils flag-o-matic libtool multilib rpm lts6-rpm

DESCRIPTION="A high-quality and portable font engine"
HOMEPAGE="http://www.freetype.org/"
SRPM="freetype-2.3.11-6.el6_2.9.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="FTL GPL-2"
SLOT="2"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"
IUSE="X auto-hinter bindist debug doc fontforge static-libs utils"

DEPEND="sys-libs/zlib
	X?	( x11-libs/libX11
		  x11-libs/libXau
		  x11-libs/libXdmcp )"

# We also need a recent fontconfig version to prevent segfaults. #166029
# July 3 2007 dirtyepic
RDEPEND="${DEPEND}
		!<media-libs/fontconfig-2.3.2-r2"

src_unpack() {
	rpm_src_unpack || die
}

src_prepare() {
	enable_option() {
		sed -i -e "/#define $1/a #define $1" \
			include/freetype/config/ftoption.h \
			|| die "unable to enable option $1"
	}

	disable_option() {
		sed -i -e "/#define $1/ { s:^:/*:; s:$:*/: }" \
			include/freetype/config/ftoption.h \
			|| die "unable to disable option $1"
	}

	if ! use bindist; then
		# See http://freetype.org/patents.html
		# ClearType is covered by several Microsoft patents in the US
		#
		# Note, this takes care of the modification provided by
		# Patch21:  freetype-2.3.0-enable-spr.patch
		enable_option FT_CONFIG_OPTION_SUBPIXEL_RENDERING
	fi

	# Note:
	# This portion of the ebuild manages the configuration setting
	# covered by the SRPM patch freetype-2.1.10-enable-ft2-bci.patch
	if use auto-hinter; then
		# Comment out the disable_option line, it's disabled
		# by default.
		# disable_option TT_CONFIG_OPTION_BYTECODE_INTERPRETER
		enable_option TT_CONFIG_OPTION_UNPATENTED_HINTING
	fi

	if use debug; then
		enable_option FT_DEBUG_LEVEL_ERROR
		enable_option FT_DEBUG_MEMORY
	fi

	enable_option FT_CONFIG_OPTION_INCREMENTAL
	disable_option FT_CONFIG_OPTION_OLD_INTERNALS

	# Handled by equivilant EL SRPM patch
	# freetype-2.2.1-enable-valid.patch
	# epatch "${FILESDIR}"/${PN}-2.3.2-enable-valid.patch

	# Remove: Patch21:  freetype-2.3.0-enable-spr.patch
	#         It's handled above.
	SRPM_PATCHLIST="Patch46:  freetype-2.2.1-enable-valid.patch
			Patch88:  freetype-multilib.patch
			Patch89:  freetype-2.3.11-CVE-2010-2498.patch
			Patch90:  freetype-2.3.11-CVE-2010-2499.patch
			Patch91:  freetype-2.3.11-CVE-2010-2500.patch
			Patch92:  freetype-2.3.11-CVE-2010-2519.patch
			Patch93:  freetype-2.3.11-CVE-2010-2520.patch
			Patch96:  freetype-2.3.11-CVE-2010-1797.patch
			Patch97:  freetype-2.3.11-CVE-2010-2805.patch
			Patch98:  freetype-2.3.11-CVE-2010-2806.patch
			Patch99:  freetype-2.3.11-CVE-2010-2808.patch
			Patch100:  freetype-2.3.11-CVE-2010-3311.patch
			Patch101:  freetype-2.3.11-CVE-2010-3855.patch
			Patch102:  freetype-2.3.11-CVE-2011-0226.patch
			Patch103:  freetype-2.3.11-CVE-2011-3256.patch
			Patch104:  freetype-2.3.11-CVE-2011-3439.patch
			Patch105:  freetype-2.3.11-CVE-2012-1126.patch
			Patch106:  freetype-2.3.11-CVE-2012-1127.patch
			Patch107:  freetype-2.3.11-CVE-2012-1130.patch
			Patch108:  freetype-2.3.11-CVE-2012-1131.patch
			Patch109:  freetype-2.3.11-CVE-2012-1132.patch
			Patch110:  freetype-2.3.11-CVE-2012-1134.patch
			Patch111:  freetype-2.3.11-CVE-2012-1136.patch
			Patch112:  freetype-2.3.11-CVE-2012-1137.patch
			Patch113:  freetype-2.3.11-CVE-2012-1139.patch
			Patch114:  freetype-2.3.11-CVE-2012-1140.patch
			Patch115:  freetype-2.3.11-CVE-2012-1141.patch
			Patch116:  freetype-2.3.11-CVE-2012-1142.patch
			Patch117:  freetype-2.3.11-CVE-2012-1143.patch
			Patch118:  freetype-2.3.11-CVE-2012-1144.patch
			Patch119:  freetype-2.3.11-bdf-overflow.patch
			Patch120:  freetype-2.3.11-array-initialization.patch"
	lts6_srpm_epatch || die

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		sed -i -e "s:\.\.\/freetype2$:../freetype-${PV}:" Makefile

		# Disable tests needing X11 when USE="-X". (bug #177597)
		if ! use X; then
			sed -i -e "/EXES\ +=\ ftview/ s:^:#:" Makefile
		fi

		SRPM_PATCHLIST="Patch5: ft2demos-2.1.9-mathlib.patch
				Patch47:  freetype-2.3.11-more-demos.patch
				Patch94:  freetype-2.3.11-CVE-2010-2527.patch
				Patch95:  freetype-2.3.11-axis-name-overflow.patch"
		lts6_srpm_epatch || die
	fi

	elibtoolize
	epunt_cxx
}

src_configure() {
	append-flags -fno-strict-aliasing

	type -P gmake &> /dev/null && export GNUMAKE=gmake
	econf \
		$(use_enable static-libs static)
}

src_compile() {
	emake || die "emake failed"

	if use utils; then
		cd "${WORKDIR}"/ft2demos-${PV}
		emake || die "ft2demos emake failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc ChangeLog README
	dodoc docs/{CHANGES,CUSTOMIZE,DEBUG,*.txt,PATENTS,TODO}

	use doc && dohtml -r docs/*

	if use utils; then
		rm "${WORKDIR}"/ft2demos-${PV}/bin/README
		for ft2demo in ../ft2demos-${PV}/bin/*; do
			./builds/unix/libtool --mode=install $(type -P install) -m 755 "$ft2demo" \
				"${D}"/usr/bin
		done
	fi

	if use fontforge; then
		# Probably fontforge needs less but this way makes things simplier...
		einfo "Installing internal headers required for fontforge"
		find src/truetype include/freetype/internal -name '*.h' | \
		while read header; do
			mkdir -p "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
			cp ${header} "${D}/usr/include/freetype2/internal4fontforge/$(dirname ${header})"
		done
	fi

	if ! use static-libs; then
		 remove_libtool_files || die "failed removing libtool files"
	fi
}

pkg_postinst() {
	echo
	elog "The utilities and demos previously bundled with freetype are now"
	elog "optional.  Enable the utils USE flag if you would like them"
	elog "to be installed."
	echo
	elog "The TrueType bytecode interpreter is no longer patented and thus no"
	elog "longer controlled by the bindist USE flag.  Enable the auto-hinter"
	elog "USE flag if you want the old USE="bindist" hinting behavior."
}
