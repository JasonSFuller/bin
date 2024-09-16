#!/bin/bash

# Compile and install git for the local user.  Targeting RHEL9 versions.
# You may need zlib, ssl, and other dependencies, but this was good enough
# for my needs.

# WARNING: This will pollute your home directory with bin, libexec, share, etc.
#   Change the `prefix="$HOME"` below to install it somewhere else.

set -e

mkdir -p ~/src/git
cd $_

# curl -fLo curl-7.76.1.tar.gz https://github.com/curl/curl/releases/download/curl-7_76_1/curl-7.76.1.tar.gz
# tar xf curl-7.76.1.tar.gz
# pushd curl-7.76.1
# ./configure --prefix="$HOME"
# make
# make install
# popd

# curl -fLo expat-2.5.0.tar.gz https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz
# tar xf expat-2.5.0.tar.gz
# pushd expat-2.5.0
# ./configure --prefix="$HOME"
# make
# make install
# popd

curl -fLo git-2.43.5.tar.gz  https://github.com/git/git/archive/refs/tags/v2.43.5.tar.gz
tar xf git-2.43.5.tar.gz
pushd git-2.43.5
make configure
./configure --prefix="$HOME"
make
make install
popd

echo -e '\n#########################################################'
echo -e '#  Done!                                                #'
echo -e '#########################################################\n'

