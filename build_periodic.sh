#! /bin/bash
set -e
#set -x

# Set up default parameters
fp_git_dir="$(dirname "$0")"
default_base_dir="$(realpath -L "$fp_git_dir/../..")"
default_code_package=gnucash
default_docs_package=gnucash-docs
default_code_repodir="${default_base_dir}"/src/${default_code_package}.git
default_docs_repodir="${default_base_dir}"/src/${default_docs_package}.git
default_revision=maint

# Read user parameter settings
if [ -f "$fp_git_dir"/custom.sh ]
then
  . "$fp_git_dir"/custom.sh
fi

# Apply defaults for all parameters the user didn't explicitly set
base_dir=${base_dir:=$default_base_dir}
code_package=${code_package:=$default_code_package}
docs_package=${docs_package:=$default_docs_package}
code_repodir="${code_repodir:=$default_code_repodir}"
docs_repodir="${docs_repodir:=$default_docs_repodir}"
revision=${revision:=$default_revision}
revision=${revision:=$revision}

. "$fp_git_dir"/functions.sh

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
if flatpak repo repo --branches | grep -qP "/$flatpak_branch\t"
then
    echo "Nothing to do: build already in repo"
    exit 0
else
    echo "Branch $flatpak_branch not found in repo, starting build"
fi

# Create the flatpak manifest
create_manifest

# Start all necessary builds in parallel
echo "Creating new flatpak [gnucash=$code_full_version, gnucash-docs=$docs_full_version]"
flatpak-builder --repo=repo --force-clean --default-branch="$flatpak_branch" build "$fp_git_dir"/org.gnucash.GnuCash.json
# Optional code to upload
