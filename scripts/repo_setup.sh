#!/bin/bash

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
