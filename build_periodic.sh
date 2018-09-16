#! /bin/bash
set -ex

fp_git_dir="$(dirname "$0")"
base_dir="$fp_git_dir/../.."

code_package=gnucash
docs_package=gnucash-docs
code_repodir="${base_dir}"/src/${code_package}.git
docs_repodir="${base_dir}"/src/${docs_package}.git
code_refspec=maint
docs_refspec=${code_refspec}
flatpak_repo=${code_package}-${code_refspec}

if [ -f "$fp_git_dir"/custom.sh ]
then
  . "$fp_git_dir"/custom.sh
fi

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
flatpak-builder --repo=repo --force-clean --default-branch="C$code_full_version-D$docs_full_version" build "$base_dir"/org.gnucash.GnuCash.json

echo -n $code_curr_rev > "$base_dir"/code_last_rev
echo -n $docs_curr_rev > "$base_dir"/docs_last_rev

# Optional code to upload
