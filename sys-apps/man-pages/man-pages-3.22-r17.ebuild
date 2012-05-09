# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/man-pages/man-pages-3.28.ebuild,v 1.3 2012/03/06 10:31:39 pacho Exp $

EAPI=4

inherit rpm lts6-rpm

DESCRIPTION="A somewhat comprehensive collection of Linux man pages"
HOMEPAGE="http://www.kernel.org/doc/man-pages/"

SRPM="man-pages-3.22-17.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"

LICENSE="as-is GPL-2 BSD"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-linux ~ia64-linux ~x86-linux"
IUSE_LINGUAS=" da de fr it ja nl pl ro ru zh_CN"
IUSE="nls ${IUSE_LINGUAS// / linguas_}"
RESTRICT="mirror binchecks"

RDEPEND="virtual/man"
PDEPEND="nls? (
	linguas_da? ( app-i18n/man-pages-da )
	linguas_de? ( app-i18n/man-pages-de )
	linguas_fr? ( app-i18n/man-pages-fr )
	linguas_it? ( app-i18n/man-pages-it )
	linguas_ja? ( app-i18n/man-pages-ja )
	linguas_nl? ( app-i18n/man-pages-nl )
	linguas_pl? ( app-i18n/man-pages-pl )
	linguas_ro? ( app-i18n/man-pages-ro )
	linguas_ru? ( app-i18n/man-pages-ru )
	linguas_zh_CN? ( app-i18n/man-pages-zh_CN )
	)
	sys-apps/man-pages-posix"

src_unpack() {
	rpm_unpack "${SRPM}" || die "rpm_unpack failed!"

	# It looks like man-pages_syscalls-01.tar.bz2 is actually
	# a tar.gz file.  The base eclass doesn't like that.
	mv "${WORKDIR}/man-pages_syscalls-01.tar.bz2" \
	   "${WORKDIR}/man-pages_syscalls-01.tar.gz" || die

	unpack "./man-pages-3.22.tar.bz2" || die "unpack failed!"

	cp "${WORKDIR}/man-pages-extralocale.tar.bz2" "${S}"
	cp "${WORKDIR}/man-suid-bins.tar.bz2" "${S}"
	cp "${WORKDIR}/man-pages_add-01.tar.bz2" "${S}"
	cp "${WORKDIR}/man-pages_syscalls-01.tar.gz" "${S}"

	cd "${S}"

	unpack "./man-pages-extralocale.tar.bz2" || die "unpack failed!"
	unpack "./man-suid-bins.tar.bz2" || die "unpack failed!"
	unpack "./man-pages_add-01.tar.bz2" || die "unpack failed!"
	unpack "./man-pages_syscalls-01.tar.gz" || die "unpack failed!"
}

src_prepare() {
	cp ${WORKDIR}/mmap.2 man2/mmap.2

	SRPM_PATCHLIST="Patch1: man-pages-1.51-iconv.patch
			Patch28: man-pages-2.46-nscd.patch
			Patch36: man-pages-2.63-unimplemented.patch
			Patch41: man-pages-2.43-rt_spm.patch
			Patch44: man-pages-2.43-fadvise.patch
			Patch45: man-pages-2.48-passwd.patch
			Patch46: man-pages-2.51-nscd-conf.patch
			Patch49: man-pages-2.63-getent.patch
			Patch50: man-pages-2.63-iconv.patch
			Patch53: man-pages-2.78-stream.patch
			Patch54: man-pages-2.80-malloc_h.patch
			Patch55: man-pages-3.22-gai.conf.patch
			Patch56: man-pages-3.22-strcpy.patch
			Patch57: man-pages-3.22-nsswitch.conf.patch
			Patch58: man-pages-3.22-sched_setaffinity.patch
			Patch59: man-pages-3.24-atanh.patch
			Patch60: man-pages-3.24-mmap64.patch
			Patch61: man-pages-3.22-swapon.patch
			Patch62: man-pages-3.22-syscalls.patch
			Patch63: man-pages-3.22-get_mempolicy.patch
			Patch64: man-pages-3.22-sd.patch
			Patch65: man-pages-3.22-pthread.patch
			Patch66: man-pages-3.22-get_timeres.patch
			Patch67: man-pages-2.39-gai.conf.patch
			Patch68: man-pages-3.22-crypt.patch
			Patch69: man-pages-3.22-getifaddrs.patch"
	lts6_srpm_epatch || die

	### And now remove those we are not going to use:

	# Part of quota
	rm -v man2/quotactl.2

	# Only briefly part of a devel version of glibc
	rm -v man3/getipnodeby{name,addr}.3 man3/freehostent.3

	# Part of libattr-devel
	rm -v man2/{,f,l}{get,list,remove,set}xattr.2

	# Problem with db x db4 (#198597) - man pages are obsolete
	rm -v man3/{btree,dbopen,hash,mpool,recno}.3

	# Remove rpcinfo page - obsolete
	rm -v man8/rpcinfo.8

	# Deprecated
	rm -v man2/pciconfig_{write,read,iobase}.2
	# Part of squid
	rm -v man8/ncsa_auth.8

	# Part of numactl package
	rm -v man5/numa_maps.5

	# We do not have sccs
	rm -f man1p/{admin,delta,get,prs,rmdel,sact,sccs,unget,val,what}.1p

	# #669768 remove obsolete man page
	rm -f man1/getent.1

}

src_configure() { :; }

src_compile() { :; }

src_install() {
	emake install prefix="${EPREFIX}/usr" DESTDIR="${D}" || die
	dodoc man-pages-*.Announce README Changes*

	# Override with Gentoo specific or additional Gentoo pages
	# cd "${WORKDIR}"/man-pages-gentoo
	# doman */* || die
	# dodoc README.Gentoo
}

pkg_postinst() {
	einfo "If you don't have a makewhatis cronjob, then you"
	einfo "should update the whatis database yourself:"
	einfo " # makewhatis -u"
}
