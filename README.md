# Build environment to build a flatpak version of GnuCash #

This repository contains code to allow building a [flatpak](https://flatpak.org/) version of GnuCash.

# System dependencies #

To use the scripts in this repository you need the following packages installed on your system:

- flatpak
- flatpak-builder
- gettext (for envsubst)
- perl

# Build recipe #
In the following recipe
we will use "flatpak" as the **base directory** in which everything will happen.

1. Create the following directory structure
```
flatpak
flatpak/src
```

2. Navigate into flatpak/src
```bash
cd flatpak/src
```

3. Clone this repo:
```bash
git clone https://github.com/Gnucash/gnucash-on-flatpak gnucash-on-flatpak.git
```

4. Clone the gnucash repo
```bash
git clone https://github.com/Gnucash/gnucash gnucash.git
```

5. Clone the gnucash-docs repo
```bash
git clone https://github.com/Gnucash/gnucash-docs gnucash-docs.git
```

6. If needed copy custom.sh-sample to custom.sh and override the variables
   found in there are desired/needed (for example if your repos are in
   a location other than the defaults).

7. Navigate back to the base directory (flatpak in our set up)
```bash
cd ..
```

8. Build the flatpak using the build_package.sh command. If no options are set this command
will build the maint branch of your gnucash and gnucash-docs repositories.
```bash
./src/gnucash-on-flatpak.git/build_package.sh
```

9. On successful completion you will now have a flatpak repo named "repo" in the flatpak
base directory. You can **install** and **run** gnucash from this directory using the typical flatpak
commands:
```bash
flatpak --user remote-add --no-gpg-verify gnc-testing-repo repo   # only once required
flatpak --user install gnc-testing-repo org.gnucash.GnuCash       # after each build
flatpak run org.gnucash.GnuCash                                   # as often as you like
# or open a shell to use included comand line tools like 'aqbanking-cli':
flatpak run --command=sh org.gnucash.GnuCash
```
Note one has to specify --no-gpg-verify because the builds are not signed.

## Flatpak branches ##

The build script will try to avoid double work. For that it will check the commit hashes
for the given revision (maint by default if no revision is passed to the build script).
If a build already exists for the combination of the gnucash and gnucash-docs commit hashes
no new build will be started.

For new combinations it will start a new build and add it in the flatpak repository. To allow
the user to select a specific build, each new build will be stored with a unique branch name.

For release builds (that is, builds starting from a tag) the branch will be
```
/app/org.gnucash.GnuCash/<arch>/<tag>
```
For example
```
/app/org/gnucash.GnuCash/x86_64/3.2
```
For non-release builds (like from 'maint') the branch name will be based on the git branch name
and git descriptions of the respective commits. The git descriptions are obtained using the
**git describe** command. So the full branch name becomes
```
/app/org.gnucash.GnuCash/<arch>/<git branch>-C<code-desc>-D<docs-desc>
```
For example
```
/app/org/gnucash.GnuCash/x86_64/maint-C3.2-290-ga20a803c8-D3.2-21-gc817132
```

With these long flatpak branch branch names it's possible to refer back exactly to the
commits in the git repositories that were used to build this flatpak from.
* The **commit hash** refs are the bit after the -g. In the example above the code was built from commit
a20a803c8 and the docs from commit c817132.
* The rest of the description give a **relative indication** of the freshness of each branch:
  * "C3.2-290" means the **code** commit was 290 commits more recent than the 3.2 tag in the gnucash repository.
  * "D3.2-21" means the **docs** commit was 21 commits more recent than the 3.2 tag in the gnucash-docs repository.
The exact numbers are not important. But C3.2-312 would be a more recent build than C3.2-290. So these
numbers are used to sort builds by how recent they are (in terms of how recent the source
is they were built from).

## Repo and build signing ##

If you want the repository and its builds to be signed, you can provide a gpg fingerprint
via gpg_key in custom.sh. The build script will use this key to sign the build artefacts.
If the gpg key is not stored in a location searched by default by the gpg tools, your can
also pass a gpg_dir directory to tell the build script where to find the gpg key.

Note: if your key is protected with a passphrase, you will be prompted for this passphrase
during build. Keep this in mind if you intend to configure automated builds.

## Synchronizing with a remote repository ##

This is the primary use case for these scripts: build locally and then push the new builds to
a remote repository so others can download and install these flatpaks.

To enable this, two additional parameters should be set in custom.sh: host and host_public.
The first (host) is how the build script can reach the remote location. This can be any
valid rsync path spec, such as a local path or a path in the form user@host:path.

The second (host_public) is where you expect guests to find the final flatpak repo. This is
typically an http(s) url or if only for local use an absolute file:///path uri.

## Flatpakref files ##

If both gpg signing and remote repository are configured, the build script will automatically
generate a gnucash-xyz.flatpakref file for each build. This file encapsulates all information
to easily install a gnucash nightly flatpak in one single command:
```bash
flatpak install --from gnucash-xyz.flatpakref
```
This can only be set up if a GPG key and a public remote site are available.

## Directory layout of a remote repository ##

The remote repository will be structured as follows:
```
<remote_uri>
<remote_uri>/build-logs/
<remote_uri>/gnucash-flatpak.gpg
<remote_uri>/<branch1>
<remote_uri>/<branch2>
...
<remote_uri>/manifests
<remote_uri>/releases
<remote_uri>/repo
```

* **build-logs** will contain logs generated for each build
* **gnucash-flatpak.gpg** is the public key of the gpg key used to sign the repository
* **<branchx>** for each (git) branch in the gnucash and gnucash-docs a build was ever started
a directroy <branchx> will be created. This directory will contain the flatpakref files for
all the builds on that branch.
* **releases** like the <branchx> directories, except this directory will contain the flatpakref
files for all the release builds
* **manifests** contains the flatpak manifest files used for each build
* **repo** the flatpak repository for all the flatpak builds. This repository will be referenced
by the various flatpakref files or can be used to manually add a flatpak remote to your local
flatpak environment.

## Repository maintenance ##

Over time the local repo will start to accumulate plenty of branches and you
may want to drop those you no longer use.

There is no single command to do so. However as a flatpak repo is an
[ostree](https://en.wikipedia.org/wiki/OSTree)
repo under the hood we can use ostree commands to clean up.

The first step is to get an overview of branches in the repo
```bash
cd <repo>
flatpak repo --branches .
```

This will list the names of all known branches in the repo. Each branch matches
one build.

Assume we want to remove all maint nightly builds for gnucash development
between 3.3 and 3.4. All these builds will have `maint-C3.3` in their name.
So let's use a bit of bash code to filter all the refs matching that pattern
and delete them.

```bash
for ref in $(ostree refs | grep maint-C3.3)
do
    ostree refs --delete $ref
done
flatpak build-update-repo --prune .
```

What this does is call `ostree refs` and filter its output to only return the
refs that match `maint-C3.3`. Then the found refs will be passed one by one
to `ostree refs --delete` to remove it from the ostree repo. This is not enough
however. We still have to tell flatpak to rebuild the list of available refs.
That's what the last command does. Adding `--prune` will also have it clear
orphaned objects from the repo. Compare that to compacting a mailbox file.

So far only the (ostree) repo part has been cleaned up. You may want to do
similar housekeeping for all the flatpakref files, buildlogs and manifests.

## Notes ##

* The script will only build the packages if there are changes in the source
  repositories since the last build.

## Finance::Quote ##

Flatpaks don't ship perl, nor cpan. So enabling Finance::Quote support requires
adding build rules for all of these in the flatpak manifest. This is a short
summary of how this was done.

1. Use https://github.com/flathub/io.github.Hexchat.Plugin.Perl/blob/master/io.github.Hexchat.Plugin.Perl.json
as an example project to get perl built in flatpak. Note this cleans way
too much of the perl installation (including the perl executable which we still need).

2. Use https://github.com/flatpak/flatpak-builder-tools/tree/master/cpan to generate
a manifest snippet with build for all the cpan modules required for Finance::Quote

3. flatpak-cpan-generator.pl is not consistently ordering the sources and build rules
between runs, which would cause a lot of clutter in our git history. To partially
alleviate this, sort the sources alphabetically using the jq tool.

4. Add perl and finance-quote modules to our manifest. The snippet generated in
the previous step will be inluded as source list of the finance-quote module.
Keeping this separate allows us to easily update cpan dependencies in the future
without interfering with other parts of the manifest.

Expressed in simple commands:

- install the required perl modules and jq tool using (example for Fedora linux)
`sudo dnf install 'perl(App::cpanminus)' 'perl(Getopt::Long::Descriptive)' 'perl(JSON::MaybeXS)' 'perl(LWP::UserAgent)' 'perl(MetaCPAN::Client)' 'perl(Pod::Simple::SimpleTree)'`
- run
```
./flatpak-cpan-generator.pl Date::Manip Finance::Quote
cat generated-sources.json | jq -S 'sort_by(.dest)' > generated-sources-sorted.json
cp generated-sources-sorted.json modules/finance-quote-sources.json
```

Note even though passing the result through jq results in a deterministic sorting in
alphabetical order of the sources, the build rules still move around between runs
of the flatpak-cpan-generator.pl script.
While slightly annoying it's not really blocking. This means the git history has
some noise in the 'make-install' lines, but we can use the differences in the
sources to properly track changes.
For the record, experiments indicate this is
already due to the way cpanminus handles dependency resolution. The order in which
same-level dependencies are processed is not stable.

## Flathub ##

Flathub builds are derived from the gnucash-on-flatpak repository and will generally
incorporate all changes made here as well with a few exceptions:

- in gnucash-on-flatpak three files are autogenerated by build_package.sh:
  - gnucash-source.json
  - gnucash-docs-source.json
  - gnucash-extra-modules.json

In the flathub source repository these are checked in source files.

- the org.gnucash.GnuCash.json file is tweaked in the flathub source repository to
  - pass a GNUCASH_BUILD_ID to the build and
  - to override the gnucash.releases.xml file.

The gnucash.releases.xml file lists package releases, that is versions
of the flathub package. There can be more than one per gnucash release
(for example to update aqbanking versions).
There are a few commands that can help with generating this file:
- `git describe --match=<major.minor>` can be used to produce the GNUCASH_BUILD_ID (just drop the -gxzy bit). Replace
`<major.minor>` with the first tag in the gnucash release series (so not 3.8b-5, but 3.8b, or 3.9 not 3.9-7).
For this to work, obviously these tags should be set on the commits that will be pushed to flathub.
- `git log --date=short --format="<li>%ad - %s (%an)</li>" <major.minor-pkg>..HEAD` a short list of commits since
the last tag ready to add in the releases file. In this case we are only interested in the changes since
the last package release so replace `<major.minor-pkg>` with the most recent tag in the repo, so 3.8b-5
rather than 3.8.

## TODO ##
- try to build gnucash-docs as an extension instead of directly in the main flatpak

# Further Readings #
- [Flatpak’s documentation](http://docs.flatpak.org/en/latest/)
- [Flathub App Submission](https://github.com/flathub/flathub/wiki/App-Submission)
- [OSTree Documentation](https://ostree.readthedocs.io/en/latest/)
