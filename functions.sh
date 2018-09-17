function prepare_repo()
{
  pushd "${repodir}"
  echo "Update repository $repodir"
  git checkout $refspec
  git fetch
  git reset --hard origin/$refspec
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
  perl -pi -e "s!{code_branch}!$code_refspec!" "$fp_git_dir"/org.gnucash.GnuCash.json
  perl -pi -e "s!{docs_branch}!$docs_refspec!" "$fp_git_dir"/org.gnucash.GnuCash.json
}
