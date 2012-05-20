# @ECLASS: lts6-rpm.eclass
# @MAINTAINER: Mitch Harder <mitch.harder@sabayon.org>
# 
# @BLURB: Supplemental Eclass for handling source rpms.
# @DESCRIPTION:
# This eclass provides some capabilities to supplement the
# gentoo rpm eclass.

inherit eutils

DEPEND=">=app-arch/rpm2targz-9.0.0.3g"

lts6_rpm_echoit() { echo "$@"; "$@"; }

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

	if [ ! -e ${spec} ]; then
		eerror "Could not find SRPM spec file, check ebuild!!!"
		die "Error locating SRPM spec file!"
	fi

	grep '^%patch' "${spec}" | \
	while read line ; do
		set -- ${line}
		p=$1
		shift
		# EPATCH_OPTS="$*"
		set -- $(grep "^P${p#%p}:" "${spec}")
		shift
		patch_target="$*"
		if [[ ! ${patch_target} ]]; then
			eerror "Check ebuild handling of SRPM patches!!!"
			die "Error parsing patch name from SRPM spec file!"
		fi
		epatch "${dir:+${dir}/}${patch_target}" || ewarn "issue"
	done
}

# @FUNCTION: lts6_srpm_epatch
# @USAGE: [spec]
# @DESCRIPTION:
# Apply patches from a list formatted at "patch[##]: [patch_name].patch".
# This facilitates copying a list of patches from a SRPM spec file.
# The past list can be copied directly, providing fewer opportunities
# for error.
#
# This function expects the patch list to be supplied in the
# SRPM_PATCHLIST variable.
lts6_srpm_epatch() {

	if [[ ${#SRPM_PATCHLIST} -eq 0 ]] ; then
		ewarn "WARNING: SRPM Patch List is Empty."
	fi

	# We need to switch between processing the list line-by-line,
	# and parameter-by-parameter, so IFS is manipulated.
	OIFS=${IFS}
	LIFS="$(echo -e "\n\r")"

	IFS=${LIFS}
	for LINE in ${SRPM_PATCHLIST}; do
		# Patches are expected to be composed of two parts,
		# a patch identifier, like "Patch0:", and then
		# the patch name itself.
		IFS=${OIFS}
		set -- ${LINE}
		listatom=$1
		if [[ "${listatom}" != *"atch"* ]]; then
			# Skip to next line if this is a comment
			# or else die.
			if [[ "${listatom:0:1}" != "#" ]] ; then
				die "SRPM_PATCHLIST error $1"
			fi
		else
			patch=$2
			epatch "${WORKDIR}/${patch}" || die
		fi
		IFS=${LIFS}
	done

	# Reset IFS to it's original value
	IFS=${OIFS}
}
