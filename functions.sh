function usage()
{
  {
    echo "Usage: $0 [-r <revision>] [-u <remote>]"
    echo "       $0 -h"
    echo
    echo "-h          display this help message"
    echo
    echo "-r revision git revision to build. Can be a branch or a tag."
    echo "            Note this branch or tag should exist in both the gnucash"
    echo "            and the gnucash-docs repository used for this build."
    echo "            Default: 'maint'"
    echo
    echo "-u remote   an optional remote location to upload the local build results to."
    echo "            This spec can take any form understood by the rsync tool:"
    echo "            a local path or an ssh host spec in the form user@host:port/path"
    echo "            If unset uploading will be skipped"
    echo "            Default: unset"
  } 1>&2
  exit 1
}

function upload_build_log()
{
  if [[ -n "$host" ]]
  then
    rsync -av "$log_file" "$host"/build-logs
  fi
}

function prepare_repo()
{
  pushd "${repodir}"
  echo "Update repository $repodir"
  git fetch
  git checkout $revision
  if git tag | grep -q "^$revision\$"
  then
    echo "Detected a tag (release) build"
    is_release="yes"
  else
    echo "No tag detected, assuming development build"
    git reset --hard origin/$revision
  fi
  popd
}

function get_versions()
{
  echo "Extracting version numbers for package $package"
  pushd "${repodir}"
  # code uses cmake, docs is still on autotools...
  #if [ -e CMakeLists.txt ]
  #then
  #  gc_version=$(grep '(PACKAGE_VERSION ' CMakeLists.txt | perl -pe 's/.*([0-9]+\.[0-9]+).*\)/$1/ge')
  #else
  #  gc_version=$(grep AC_INIT configure.ac | perl -pe 's/.*([0-9]+\.[0-9]+).*\)/$1/ge')
  #fi
  gc_commit=$(git reflog | head -n1 | awk '{print $1}')
  #gc_full_version=${gc_version}-nightly.git.${gc_commit}
  gc_full_version=$(git describe)
  popd
}

function create_manifest()
{
  echo "Writing org.gnucash.GnuCash.json manifest file"
  cp "$fp_git_dir"/org.gnucash.GnuCash.json.tpl "$fp_git_dir"/org.gnucash.GnuCash.json
  perl -pi -e "s!{code_repo}!$code_repodir!" "$fp_git_dir"/org.gnucash.GnuCash.json
  perl -pi -e "s!{docs_repo}!$docs_repodir!" "$fp_git_dir"/org.gnucash.GnuCash.json
  perl -pi -e "s!{code_branch}!$revision!" "$fp_git_dir"/org.gnucash.GnuCash.json
  perl -pi -e "s!{docs_branch}!$revision!" "$fp_git_dir"/org.gnucash.GnuCash.json
}
