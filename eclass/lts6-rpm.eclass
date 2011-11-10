# @ECLASS: lts6-rpm.eclass
# @MAINTAINER: Mitch Harder <mitch.harder@sabayon.org>
# 
# @BLURB: Supplemental Eclass for handling source rpms.
# @DESCRIPTION:
# This eclass provides some capabilities to supplement the
# gentoo rpm eclass.

inherit eutils

DEPEND=">=app-arch/rpm2targz-9.0.0.3g"

# @FUNCTION: lts6_rpm_spec_epatch
# @USAGE: [spec]
# @DESCRIPTION:
# Read the specified spec (defaults to ${PN}.spec) and attempt to apply
# all the patches listed in it.  If the spec does funky things like moving
# files around, well this won't handle that.
#
# The lts6 version is a copy of the gentoo rpm eclass version, except
# it omits EPATCH_OPTS, which was found to interfer in some builds.
lts6_rpm_spec_epatch() {
	local p spec=${1:-${PN}.spec}
	local dir=${spec%/*}
	grep '^%patch' "${spec}" | \
	while read line ; do
		set -- ${line}
		p=$1
		shift
		# EPATCH_OPTS="$*"
		set -- $(grep "^P${p#%p}: " "${spec}")
		shift
		epatch "${dir:+${dir}/}$*"
	done
}

