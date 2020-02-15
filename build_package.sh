#! /bin/bash
set -e
#set -x

# Preset defaults for options that can be set via custom.sh
fp_git_dir="$(dirname "$0")"
default_base_dir="$(realpath -L "$fp_git_dir/../..")"
default_code_package=gnucash
default_docs_package=gnucash-docs
default_code_repodir="${default_base_dir}"/src/${default_code_package}.git
default_docs_repodir="${default_base_dir}"/src/${default_docs_package}.git
default_fp_repo=repo
host=
host_public=
gpg_key=
gpg_dir=

# Read options set via custom.sh
if [ -f "$fp_git_dir"/custom.sh ]
then
  . "$fp_git_dir"/custom.sh
fi


# Apply defaults for all options not explicitly set in custom.sh
base_dir=${base_dir:=$default_base_dir}
code_package=${code_package:=$default_code_package}
docs_package=${docs_package:=$default_docs_package}
code_repodir="${code_repodir:=$default_code_repodir}"
docs_repodir="${docs_repodir:=$default_docs_repodir}"
fp_repo=${fp_repo=$default_fp_repo}

# Preset defaults for options that can be passed via the command line
revision=maint

. "$fp_git_dir"/functions.sh

# Parse command line options
while getopts "hr:c:d:" o; do
    case "${o}" in
        r)
            revision=${OPTARG}
            ;;
        c)
            code_revision=${OPTARG}
            ;;
        d)
            docs_revision=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

is_release="undecided"
code_revision=${code_revision:-${revision}}
docs_revision=${docs_revision:-${revision}}

# Set up logging
local_log_dir="$base_dir/logs"
mkdir -p "$local_log_dir"
time_stamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="build-$revision-$time_stamp.log"
exec > >(tee "$local_log_dir/$log_file") 2>&1

# Create the base directory on the host where all generated files will be uploaded to.
# This will be a noop if either no host is set or the directory already exists
create_remote_dir "$host"

  # Upload inital build log so everyone knows the build has started
echo "Starting flatpak build run for $revision"
upload_build_log

trap cleanup ERR

# Check for new commits in code
package=${code_package}
repodir=${code_repodir}
prepare_repo ${code_revision}
get_versions

code_curr_rev=${gc_commit}
code_full_version=${gc_full_version}

# Check for new commits in docs
package=${docs_package}
repodir=${docs_repodir}
prepare_repo ${docs_revision}
get_versions

docs_curr_rev=${gc_commit}
docs_full_version=${gc_full_version}

# Compose the default branch name to use in the flatpak repo
fp_branch="$revision-C$code_full_version-D$docs_full_version"

# Release builds start from tarballs and need checksums for the manifest
if [[ "${is_release}" == "yes" ]]
then
    build_type=tar
    fp_branch="$revision"
    get_checksums
else
    build_type=git
fi

# Set up gpg
prepare_gpg
# Create the flatpak manifest
create_manifest
# Create the flatpakref file
create_flatpakref
# Create the flatpakrepo file
create_flatpakrepo

# Prepare build environment by installing the correct sdk
setup_sdk

# Start all necessary builds in parallel
echo "Creating new flatpak [gnucash=$code_full_version, gnucash-docs=$docs_full_version]"
flatpak-builder $gpg_parms --repo=$fp_repo --force-clean --default-branch="$fp_branch" build "$fp_git_dir"/org.gnucash.GnuCash.json

# Optional code to upload
if [[ -n "$host" ]]
then
  echo "Uploading flatpak manifest 'org.gnucash.GnuCash-$fp_branch.json'"
  create_remote_dir "$host"/manifests
  create_remote_dir "$host"/manifests/$remote_branch_dir
  create_remote_dir "$host"/manifests/$remote_branch_dir/$fp_branch
  rsync -a "$fp_git_dir"/org.gnucash.GnuCash.json "$fp_git_dir"/gnucash.json "$fp_git_dir"/modules "$host/manifests/$remote_branch_dir/$fp_branch"

  echo "Synchronizing flatpak repository"
  rsync -a $fp_repo "$host"

  # Upload the flatpak ref file if we created one
  if [[ -n "$fp_ref_file" ]]
  then
    echo "Uploading flatpakref file '$fp_ref_file'"
    create_remote_dir "$host"/$remote_branch_dir
    rsync -a "$fp_ref_dir_local"/$fp_ref_file "$host"/$remote_branch_dir
  fi

  # Upload the flatpakrepo file if we created one
  if [[ -n "$fp_repo_file" ]]
  then
    echo "Uploading flatpakref file '$fp_repo_file'"
    create_remote_dir "$host"
    rsync -a "$fp_repo_dir_local"/$fp_repo_file "$host"
  fi
fi

upload_build_log

# Note: command to get revision only tags sorted by increasing rev numbers: git tag --list '[0-9].*' --sort=v:refname
