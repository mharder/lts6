# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/Attic/binutils-2.20.51.0.12.ebuild,v 1.2 2010/12/16 10:46:58 vapier dead $

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils rpm lts6-rpm

# BVER=${BINUTILS_VER:-${PV}}
SRPM="binutils-2.20.51.0.2-5.28.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}
	mirror://gentoo/binutils-${PV}-patches-${PATCHVER}.tar.bz2"
RESTRICT="mirror"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd -sparc-fbsd ~x86-fbsd"

# Maintainer notes:
# "Patch02: binutils-2.20.51.0.2-ppc64-pie.patch" is handled by
# 03_all_binutils-2.15.92.0.2-ppc64-pie.patch in the Gentoo patchset
#
# Patch03: binutils-2.20.51.0.2-ia64-lib64.patch:
#    Handled specially later only on ia64 arch.
SRPM_PATCHLIST="Patch01: binutils-2.20.51.0.2-libtool-lib64.patch
# Patch02: binutils-2.20.51.0.2-ppc64-pie.patch
# Patch03: binutils-2.20.51.0.2-ia64-lib64.patch
Patch04: binutils-2.20.51.0.2-envvar-revert.patch
Patch05: binutils-2.20.51.0.2-version.patch
Patch06: binutils-2.20.51.0.2-set-long-long.patch
Patch07: binutils-2.20.51.0.2-build-id.patch
Patch08: binutils-2.20.51.0.2-add-needed.patch
Patch09: binutils-2.20.51.0.2-ifunc-ld-s.patch
Patch10: binutils-2.20.51.0.2-lwp.patch
Patch11: binutils-2.20.51.0.2-gas-expr.patch
Patch12: binutils-2.20.51.0.2-pie-perm.patch
Patch13: binutils-2.20.51.0.2-ppc64-ifunc-nocombreloc.patch
Patch14: binutils-2.20.51.0.2-ppc64-tls-transitions.patch
Patch15: binutils-2.20.51.0.2-readelf-dynamic.patch
Patch16: binutils-2.20.51.0.2-xop.patch
Patch17: binutils-2.20.51.0.2-xop2.patch
Patch18: binutils-2.20.51.0.2-xop3.patch
Patch19: binutils-2.20.51.0.2-rh545384.patch
Patch20: testsuite.patch
Patch21: binutils-rh576129.patch
Patch22: binutils-amd-bni.patch
Patch23: binutils-lwp-16bit.patch
Patch24: binutils-2.20.51.0.2-ld-r.patch
Patch25: binutils-rh578576.patch
Patch26: binutils-rh587788.patch
Patch27: binutils-rh588825.patch
Patch28: binutils-rh578661.patch
Patch29: binutils-rh633448.patch
Patch30: binutils-rh464723.patch
Patch31: binutils-rh631540.patch
Patch32: binutils-rh614443.patch
Patch33: binutils-rh663587.patch
Patch34: binutils-rh679435.patch
Patch35: binutils-rh680143.patch
Patch36: binutils-rh697703.patch
Patch37: binutils-rh698005.patch
Patch38: binutils-rh689829.patch
Patch39: binutils-rh664640.patch
Patch40: binutils-rh701586.patch
Patch41: binutils-rh707387.patch
Patch42: binutils-rh696494.patch
Patch43: binutils-rh714824.patch
Patch44: binutils-rh721079.patch
Patch45: binutils-rh696368.patch
Patch46: binutils-rh733122.patch"

src_unpack() {
	rpm_src_unpack || die

	# Maintainer Notes:
	# Much of this section is copied from the toolchain-binutils.eclass
	# tc-binutils_apply_patches section.  However, SRPM patches need to
	# be applied in the middle.
	cd "${S}"

	if ! use vanilla ; then
		[[ ${SYMLINK_LIB} != "yes" ]] && EPATCH_EXCLUDE+=" 65_all_binutils-*-amd64-32bit-path.patch"
		if [[ -n ${PATCHVER} ]] ; then
			EPATCH_SOURCE=${WORKDIR}/patch
			if [[ ${CTARGET} == mips* ]] ; then
				# remove gnu-hash for mips (bug #233233)
				EPATCH_EXCLUDE+=" 77_all_generate-gnu-hash.patch"
			fi
			[[ -n $(ls "${EPATCH_SOURCE}"/*.bz2 2>/dev/null) ]] \
				&& EPATCH_SUFFIX="patch.bz2" \
				|| EPATCH_SUFFIX="patch"
			epatch
		fi
		if [[ -n ${UCLIBC_PATCHVER} ]] ; then
			EPATCH_SOURCE=${WORKDIR}/uclibc-patches
			[[ -n $(ls "${EPATCH_SOURCE}"/*.bz2 2>/dev/null) ]] \
				&& EPATCH_SUFFIX="patch.bz2" \
				|| EPATCH_SUFFIX="patch"
			EPATCH_MULTI_MSG="Applying uClibc fixes ..." \
			epatch
		elif [[ ${CTARGET} == *-uclibc* ]] ; then
			# starting with binutils-2.17.50.0.17, we no longer need
			# uClibc patchsets :D
			if grep -qs 'linux-gnu' "${S}"/ltconfig ; then
				die "sorry, but this binutils doesn't yet support uClibc :("
			fi
		fi
		[[ ${#PATCHES[@]} -gt 0 ]] && epatch "${PATCHES[@]}"
		epatch_user
	fi

	lts6_srpm_epatch || die

	if [[ ${CTARGET} == sparc* ]] ; then
		SRPM_PATCHLIST="Patch03: binutils-2.20.51.0.2-ia64-lib64.patch"
		lts6_srpm_epatch || die
	fi

	# fix locale issues if possible #122216
	if [[ -e ${FILESDIR}/binutils-configure-LANG.patch ]] ; then
		einfo "Fixing misc issues in configure files"
		for f in $(grep -l 'autoconf version 2.13' $(find "${S}" -name configure)) ; do
			ebegin "  Updating ${f/${S}\/}"
			patch "${f}" "${FILESDIR}"/binutils-configure-LANG.patch >& "${T}"/configure-patch.log \
				|| eerror "Please file a bug about this"
			eend $?
		done
	fi

	# fix conflicts with newer glibc #272594
	if [[ -e libiberty/testsuite/test-demangle.c ]] ; then
		sed -i 's:\<getline\>:get_line:g' libiberty/testsuite/test-demangle.c
	fi

	# Fix po Makefile generators
	sed -i \
		-e '/^datadir = /s:$(prefix)/@DATADIRNAME@:@datadir@:' \
		-e '/^gnulocaledir = /s:$(prefix)/share:$(datadir):' \
		*/po/Make-in || die "sed po's failed"

	# The following were psuedo copied from the SRPM spec file
	# On ppc64 we might use 64KiB pages
	sed -i -e '/#define.*ELF_COMMONPAGESIZE/s/0x1000$/0x10000/' bfd/elf*ppc.c

	# LTP sucks
	perl -pi -e 's/i\[3-7\]86/i[34567]86/g' */conf*
	# sed -i -e 's/%%{release}/%{release}/g' bfd/Makefile{.am,.in}
	# sed -i -e '/^libopcodes_la_\(DEPENDENCIES\|LIBADD\)/s,$, ../bfd/libbfd.la,' \
	#	opcodes/Makefile.{am,in}

	# Build libbfd.so and libopcodes.so with -Bsymbolic-functions if possible.
	if ${CC} ${CFLAGS} -v --help 2>&1 | grep -q -- -Bsymbolic-functions; then
		sed -i -e 's/^libbfd_la_LDFLAGS = /&-Wl,-Bsymbolic-functions /' \
			bfd/Makefile.{am,in}
		sed -i -e 's/^libopcodes_la_LDFLAGS = /&-Wl,-Bsymbolic-functions /' \
			opcodes/Makefile.{am,in}
	fi

	# $PACKAGE is used for the gettext catalog name.
	sed -i -e 's/^ PACKAGE=/ PACKAGE=%{?cross}/' */configure

	case ${CTARGET} in i?86*|sparc*|ppc*|s390*|sh*)
		CFLAGS="${CFLAGS} --enable-64-bit-bfd"
		;;
	esac

	case ${CTARGET} in ia64*)
		CFLAGS="${CFLAGS} --enable-targets=i386-linux"
		;;
	esac

	case ${CTARGET} in ppc*|ppc64*)
		CFLAGS="${CFLAGS} --enable-targets=spu"
		;;
	esac

	# Run misc portage update scripts
	gnuconfig_update
	elibtoolize --portage --no-uclibc
}
