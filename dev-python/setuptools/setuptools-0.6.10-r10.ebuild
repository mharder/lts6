# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/setuptools/Attic/setuptools-0.6.10.ebuild,v 1.11 2011/03/23 22:00:59 arfrever dead $

EAPI="4"
SUPPORT_PYTHON_ABIS="1"

inherit distutils eutils rpm lts6-rpm

MY_PN="distribute"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Distribute (fork of Setuptools) is a collection of extensions to Distutils"
HOMEPAGE="http://pypi.python.org/pypi/distribute"
SRPM="python-setuptools-0.6.10-3.el6.src.rpm"
SRC_URI="mirror://lts62/vendor/${SRPM}"
RESTRICT="mirror"

LICENSE="PSF-2.2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODNAME="easy_install.py pkg_resources.py setuptools site.py"
DOCS="README.txt docs/easy_install.txt docs/pkg_resources.txt docs/setuptools.txt zpl.txt psfl.txt"

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-0.6_rc7-noexe.patch"
	epatch "${FILESDIR}/distribute-0.6.12-disable_versioned_easy_install.patch"

	SRPM_PATCHLIST="Patch0:   distribute-b045d0750c13.diff"
	lts6_srpm_epatch || die

	# Remove tests that access the network (bugs #198312, #191117)
	rm setuptools/tests/test_packageindex.py
	cp "${WORKDIR}/zpl.txt" "${S}"
	cp "${WORKDIR}/psfl.txt" "${S}"
}

src_test() {
	# test_install_site_py fails with disabled byte-compiling in Python 2.7 / >=3.2.
	python_enable_pyc

	tests() {
		PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" test
	}
	python_execute_function tests

	python_disable_pyc
	find "(" -name "*.pyc" -o -name "*\$py.class" ")" -print0 | xargs -0 rm -f
	find -name "__pycache__" -print0 | xargs -0 rmdir
}

src_install() {
	DONT_PATCH_SETUPTOOLS="1" distutils_src_install
}
