#!/usr/bin/env bash

#
# Build the  MacOS artifacts 
#

set -euo pipefail
set -x

# Fix broken homebrew on the CircleCI image:

git -C "/usr/local/Homebrew/Library/Taps/homebrew/homebrew-core" fetch --unshallow

for pkg in cairo libexif xz libarchive python3 wget cmake; do
    brew list $pkg 2>/dev/null | head -10 || brew install $pkg
done

wget -q http://opencpn.navnux.org/build_deps/wx312_opencpn50_macos109.tar.xz
tar xJf wx312_opencpn50_macos109.tar.xz -C /tmp
export PATH="/usr/local/opt/gettext/bin:$PATH"
echo 'export PATH="/usr/local/opt/gettext/bin:$PATH"' >> ~/.bash_profile
 
rm -rf build && mkdir build && cd build
cmake -DOCPN_USE_LIBCPP=ON \
  -DwxWidgets_CONFIG_EXECUTABLE=/tmp/wx312_opencpn50_macos109/bin/wx-config \
  -DwxWidgets_CONFIG_OPTIONS="--prefix=/tmp/wx312_opencpn50_macos109" \
  -DCMAKE_INSTALL_PREFIX=/tmp/opencpn -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -sj2
make package
ls -lR
