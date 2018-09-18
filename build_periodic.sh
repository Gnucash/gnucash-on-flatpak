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
default_revision=maint
default_fp_repo=repo

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
host=

. "$fp_git_dir"/functions.sh

# Parse command line options
while getopts "hr:u:" o; do
    case "${o}" in
        r)
            revision=${OPTARG}
            ;;
        u)
            host=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

is_release="no"

# Set up logging
mkdir -p "$base_dir/logs"
time_stamp=$(date +%Y-%m-%d-%H-%M-%S)
log_file="$base_dir/logs/build-$revision-$time_stamp.log"
exec > >(tee "$log_file") 2>&1

if [[ -n "$host" ]]
then
  # Bootstrap initial directory structure on the host
  # This will be a noop if the structure already exists
  mkdir fake
  rsync -a fake/ "$host"
  rsync -a fake/ "$host"/build-logs
  rsync -a fake/ "$host"/manifests
  rmdir fake
fi

  # Upload inital build log so everyone knows the build has started
echo "Starting flatpak build run for $revision"
upload_build_log

# Check for new commits in code
package=${code_package}
repodir=${code_repodir}
prepare_repo
get_versions

code_curr_rev=${gc_commit}
code_full_version=${gc_full_version}

# Check for new commits in docs
package=${docs_package}
repodir=${docs_repodir}
prepare_repo
get_versions

docs_curr_rev=${gc_commit}
docs_full_version=${gc_full_version}

# Simplify flatpak package version if code and docs are on the same full_version
# In practice this only happens when a tag is checked out, so as the code
# is currently written this means it only happens for release builds
if [[ "$code_full_version" == "$docs_full_version" ]]
then
    flatpak_branch="$code_full_version"
else
    flatpak_branch="$revision-C$code_full_version-D$docs_full_version"
fi

echo "Checking for existing build of revision $flatpak_branch"
# The command below will print an error on first run as the repo doesn't exist yet
# You can safely ignore the error message
if flatpak repo $fp_repo --branches | grep -qP "/$flatpak_branch\t"
then
    echo "Nothing to do: build already in repo"
    upload_build_log
    exit 0
else
    echo "Branch $flatpak_branch not found in repo, starting build"
fi

# Create the flatpak manifest
create_manifest

# Start all necessary builds in parallel
echo "Creating new flatpak [gnucash=$code_full_version, gnucash-docs=$docs_full_version]"
flatpak-builder --repo=$fp_repo --force-clean --default-branch="$flatpak_branch" build "$fp_git_dir"/org.gnucash.GnuCash.json

# Optional code to upload
if [[ -n "$host" ]]
then
  mkdir fake
  if [[ "$is_release" = "yes" ]]
  then
    rsync -a fake/ "$host"/releases
    fp_ref_dir="$host"/releases
  else
    rsync -a fake/ "$host"/$revision
    fp_ref_dir="$host"/$revision
  fi
  rmdir fake

  rsync -a "$fp_git_dir"/org.gnucash.GnuCash.json "$host/manifests/org.gnucash.GnuCash-$flatpak_branch.json"
  rsync -a $fp_repo "$host"
  # Upload the flatpak ref file  -- todo
fi

upload_build_log
