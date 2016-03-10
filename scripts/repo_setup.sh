#!/bin/bash

WHOAMI=$(whoami)

# Adapted from https://wiki.debian.org/AutomateBackports

umask 022

# Create the directory structure
mkdir -p ~/Backports/debian/pool/main
mkdir -p ~/Backports/debian/dists/wheezy/main/binary-amd64
mkdir -p ~/Backports/debian/dists/wheezy/main/source

cd ~/Backports/debian

# apt (within pbuilder) will fail if we don't have a blank package listing
touch dists/wheezy/main/binary-amd64/Packages

# Configure the repo
cat > dists/wheezy/main/binary-amd64/Release <<EOF
Archive: unstable
Version: 4.0
Component: main
Architecture: amd64
EOF

cat > dists/wheezy/main/source/Release <<EOF
Archive: unstable
Version: 4.0
Component: main
Architecture: source
EOF

cat >aptftp.conf <<EOF
APT::FTPArchive::Release {
  Suite "wheezy";
  Codename "wheezy";
  Architectures "amd64";
  Components "main";
  Description "Experimental Backports Repo";
}
EOF

cat >aptgenerate.conf <<EOF
Dir::ArchiveDir ".";
Dir::CacheDir ".";
TreeDefault::Directory "pool/";
TreeDefault::SrcDirectory "pool/";
Default::Packages::Extensions ".deb";
Default::Packages::Compress ". gzip bzip2";
Default::Sources::Compress "gzip bzip2";
Default::Contents::Compress "gzip bzip2";

BinDirectory "dists/wheezy/main/binary-amd64" {
  Packages "dists/wheezy/main/binary-amd64/Packages";
  Contents "dists/wheezy/Contents-amd64";
  SrcPackages "dists/wheezy/main/source/Sources";
};

Tree "dists/wheezy" {
  Sections "main";
  Architectures "amd64 source";
};
EOF

cat >~/.dupload.conf <<EOF
package config;

$preupload{'changes'} = '';
$cfg{"localhost"} = {
fqdn => "localhost",
method => "scpb",
incoming => "/home/${WHOAMI}/Backports/debian/pool/main",
# The dinstall on ftp-master sends emails itself
dinstall_runs => 1,
};

$cfg{'localhost'}{postupload}{'changes'} = "
echo 'cd /home/${WHOAMI}/Backports/debian ;
apt-ftparchive generate -c=aptftp.conf aptgenerate.conf;
apt-ftparchive release -c=aptftp.conf dists/wheezy >dists/wheezy/Release;
rm -f dists/wheezy/Release.gpg ;
gpg -u 2F48295A -bao dists/wheezy/Release.gpg dists/wheezy/Release'|sh ;
echo 'Package archive created!'";

1;
EOF
