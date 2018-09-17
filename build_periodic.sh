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
default_code_refspec=maint
default_docs_refspec=${default_code_refspec}

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
code_refspec=${code_refspec:=$default_code_refspec}
docs_refspec=${docs_refspec:=$default_docs_refspec}

. "$fp_git_dir"/functions.sh

# Check for new commits in code
package=${code_package}
repodir=${code_repodir}
refspec=${code_refspec}
prepare_repo
get_versions

code_curr_rev=${gc_commit}
code_full_version=${gc_full_version}
touch "$base_dir"/code_last_rev
code_last_rev=$(cat "$base_dir"/code_last_rev)

# Check for new commits in docs
package=${docs_package}
repodir=${docs_repodir}
refspec=${docs_refspec}
prepare_repo
get_versions

docs_curr_rev=${gc_commit}
docs_full_version=${gc_full_version}
touch "$base_dir"/docs_last_rev
docs_last_rev=$(cat "$base_dir"/docs_last_rev)

if [[ "$code_curr_rev" == "$code_last_rev" ]] &&
   [[ "$docs_curr_rev" == "$docs_last_rev" ]]
then
    echo "No changes - exiting"
    exit 0
fi

# Create the flatpak manifest
create_manifest

# Start all necessary builds in parallel
echo "Creating new flatpak [gnucash=$code_full_version, gnucash-docs=$docs_full_version]"
flatpak-builder --repo=repo --force-clean --default-branch="C$code_full_version-D$docs_full_version" build "$fp_git_dir"/org.gnucash.GnuCash.json

echo -n $code_curr_rev > "$base_dir"/code_last_rev
echo -n $docs_curr_rev > "$base_dir"/docs_last_rev

# Optional code to upload
