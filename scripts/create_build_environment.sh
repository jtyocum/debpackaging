#!/bin/bash

WHOAMI=$(whoami)

# Use cowbuilder to create a COW environment for pbuilder
sudo cowbuilder --create --distribution wheezy --basepath /var/cache/pbuilder/base-wheezy.cow

# Add our local repo, so we can use our own packages
gpg --export -a 2F48295A | sudo apt-key --keyring /var/cache/pbuilder/base-wheezy.cow/etc/apt/trusted.gpg add -
sudo echo "deb file:///home/${WHOAMI}/Backports/debian wheezy main" >> /var/cache/pbuilder/base-wheezy.cow/etc/apt/sources.list

# Create hook to force apt-get update
sudo mkdir -p /usr/lib/pbuilder/hooks
sudo cat >/usr/lib/pbuilder/hooks/D90update <<EOF
#!/bin/sh
/usr/bin/apt-get update
EOF
sudo chmod 755 /usr/lib/pbuilder/hooks/D90update

# Configure pbuilder
cat >~/.pbuilderrc-wheezy <<EOF
# pbuilder defaults; edit /etc/pbuilderrc to override these and see
# pbuilderrc.5 for documentation

#BASETGZ=/var/cache/pbuilder/base.tgz
BASEPATH=/var/cache/pbuilder/base-wheezy.cow
#EXTRAPACKAGES=""
#export DEBIAN_BUILDARCH=athlon
BUILDPLACE=/var/cache/pbuilder/build/
MIRRORSITE=http://cdn.debian.net/debian
OTHERMIRROR="deb http://httpredir.debian.org/debian/ wheezy-backports main contrib non-free|deb file:///home/$WHOAMI}/Backports/debian wheezy main"
#export http_proxy=http://your-proxy:8080/
USEPROC=yes
USEDEVPTS=yes
USEDEVFS=no
BUILDRESULT=/var/cache/pbuilder/result/

# specifying the distribution forces the distribution on "pbuilder update"
DISTRIBUTION=wheezy
# specifying the architecture passes --arch= to debootstrap; the default is
# to use the architecture of the host
#ARCHITECTURE=\`dpkg --print-architecture\`
# specifying the components of the distribution, for instance to enable all
# components on Debian use "main contrib non-free" and on Ubuntu "main
# restricted universe multiverse"
COMPONENTS="main contrib non-free"
#specify the cache for APT
APTCACHE="/var/cache/pbuilder/aptcache/"
APTCACHEHARDLINK="yes"
REMOVEPACKAGES=""
HOOKDIR="/usr/lib/pbuilder/hooks"
#HOOKDIR=""
# NB: this var is private to pbuilder; ccache uses "CCACHE_DIR" instead
# CCACHEDIR="/var/cache/pbuilder/ccache"
CCACHEDIR=""

# make debconf not interact with user
export DEBIAN_FRONTEND="noninteractive"

DEBEMAIL=""

#for pbuilder debuild
BUILDSOURCEROOTCMD="fakeroot"
PBUILDERROOTCMD="sudo -E"
# use cowbuilder for pdebuild
#PDEBUILD_PBUILDER="cowbuilder"

# additional build results to copy out of the package build area
#ADDITIONAL_BUILDRESULTS=(xunit.xml .coverage)

# command to satisfy build-dependencies; the default is an internal shell
# implementation which is relatively slow; there are two alternate
# implementations, the "experimental" implementation,
# "pbuilder-satisfydepends-experimental", which might be useful to pull
# packages from experimental or from repositories with a low APT Pin Priority,
# and the "aptitude" implementation, which will resolve build-dependencies and
# build-conflicts with aptitude which helps dealing with complex cases but does
# not support unsigned APT repositories
PBUILDERSATISFYDEPENDSCMD="/usr/lib/pbuilder/pbuilder-satisfydepends"

# Arguments for $PBUILDERSATISFYDEPENDSCMD.
# PBUILDERSATISFYDEPENDSOPT=()

# You can optionally make pbuilder accept untrusted repositories by setting
# this option to yes, but this may allow remote attackers to compromise the
# system. Better set a valid key for the signed (local) repository with
# $APTKEYRINGS (see below).
ALLOWUNTRUSTED=no

# Option to pass to apt-get always.
export APTGETOPT=()
# Option to pass to aptitude always.
export APTITUDEOPT=()

#Command-line option passed on to dpkg-buildpackage.
#DEBBUILDOPTS="-IXXX -iXXX"
DEBBUILDOPTS=""

#APT configuration files directory
APTCONFDIR=""

# the username and ID used by pbuilder, inside chroot. Needs fakeroot, really
BUILDUSERID=1234
BUILDUSERNAME=pbuilder

# BINDMOUNTS is a space separated list of things to mount
# inside the chroot.
BINDMOUNTS="/home/${WHOAMI}/Backports"

# Set the debootstrap variant to 'buildd' type.
DEBOOTSTRAPOPTS=(
    '--variant=buildd'
    '--keyring' '/usr/share/keyrings/debian-archive-keyring.gpg'
    )
# or unset it to make it not a buildd type.
# unset DEBOOTSTRAPOPTS

# Keyrings to use for package verification with apt, not used for debootstrap
# (use DEBOOTSTRAPOPTS). By default the debian-archive-keyring package inside
# the chroot is used.
APTKEYRINGS=()

# Set the PATH I am going to use inside pbuilder: default is "/usr/sbin:/usr/bin:/sbin:/bin"
export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

# SHELL variable is used inside pbuilder by commands like 'su'; and they need sane values
export SHELL=/bin/bash

# The name of debootstrap command, you might want "cdebootstrap".
DEBOOTSTRAP="debootstrap"

# default file extension for pkgname-logfile
PKGNAME_LOGFILE_EXTENTION="_\$(dpkg --print-architecture).build"

# default PKGNAME_LOGFILE
PKGNAME_LOGFILE=""

# default AUTOCLEANAPTCACHE
AUTOCLEANAPTCACHE=""

#default COMPRESSPROG
COMPRESSPROG="gzip"
EOF
