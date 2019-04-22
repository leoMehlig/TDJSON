#!/bin/sh

fold_start() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
}

fold_end() {
  echo -e "\ntravis_fold:end:$1\r"
}

show_progress() {
  PID=$!
  i=1
  sp="/-\|"
  echo -n ' '
  while kill -0 $PID 2> /dev/null
  do
      printf "\b${sp:i++%${#sp}:1}"
      sleep 60
  done
}

fold_start td_checkout "Checkout td at tag ${$TRAVIS_TAG}"

git clone https://github.com/tdlib/td
cd td
git checkout tags/$TRAVIS_TAG
# git checkout tags/v1.3.0
cd ..

fold_end td_checkout

td_path=$(pwd)/td

build_path=$(pwd)/build

rm -rf build
mkdir -p build
cd build

set_options() {
  platform=$1
  echo "Platform: ${platform} arg: $1"
  openssl_path=$(pwd)/../third_party/openssl/${platform}
  openssl_crypto_library="${openssl_path}/lib/libcrypto.a"
  openssl_ssl_library="${openssl_path}/lib/libssl.a"
  options="$options -DOPENSSL_FOUND=1"
  options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
  # options="$options -OPENSSL_ROOT_DIR=${openssl_ssl_library}"
  options="$options -DOPENSSL_INCLUDE_DIR=${openssl_path}/include"
  options="$options -DOPENSSL_LIBRARIES=${openssl_ssl_library}"
  options="$options -DCMAKE_BUILD_TYPE=Release"
  # options="$options -DCMAKE_C_COMPILER=/usr/local/opt/llvm/bin/clang"
  # options="$options -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm/bin/clang++"
}

make_lipo() {
  platform=$0
  fold_start td_lipo "Lipo td for ${platform}"
  cd build_path
  mkdir -p $platform
  libs="libtdclient.a libtdsqlite.a libtdcore.a libtdactor.a libtdutils.a libtdjson_private.a libtddb.a libtdjson_static.a libtdnet.a"
  for lib_path in  $libs;
  do
      lib="install-${platform}/lib/${lib_path}"
      lib_simulator="install-${platform}-simulator/lib/${lib_path}"
      lipo -create $lib $lib_simulator -o $platform/$lib_path
  done
  fold_end td_lipo
}

copy_installs() {
  $platform = $1
  fold_start td_copy "Copying libs to destination for ${platform}"
  mkdir -p $platform/include
  rsync --recursive install-${platform}/include/ ${platform}/include/
  fold_end td_copy
}

build_macos() {
  set_options "macOS"
  fold_start td_build "Building td for ${platform}"
  platform="macOS"
  build="build-${platform}"
  install="install-${platform}"
  rm -rf $build
  mkdir -p $build
  mkdir -p $install
  cd $build
  echo "cmake $td_path $options -DCMAKE_INSTALL_PREFIX=../${install}"
  cmake $td_path $options -DCMAKE_INSTALL_PREFIX=../${install}
  # cmake --build . --target prepare_cross_compiling
  make -j3 install || exit
  cd ..
  fold_end td_build
  copy_installs "macOS"
}


build_ios() {
  set_options "iOS"
  simulator=$1
  platform=$2
  fold_start td_build "Building td for ${platform} (sim=${simulator})"
  build="build-${platform}"
  install="install-${platform}"
  if [[ $simulator = "1" ]]; then
    build="${build}-simulator"
    install="${install}-simulator"
    ios_platform="SIMULATOR"
  else
    ios_platform="OS"
  fi
  if [[ $platform = "watchOS" ]]; then
    ios_platform="WATCH${ios_platform}"
  fi
  if [[ $platform = "tvOS" ]]; then
    ios_platform="TV${ios_platform}"
  fi
  echo $ios_platform
  rm -rf $build
  mkdir -p $build
  mkdir -p $install
  cd $build
  echo "cmake $td_path $options -DIOS_PLATFORM=${ios_platform} -DCMAKE_TOOLCHAIN_FILE=${td_path}/CMake/iOS.cmake -DIOS_DEPLOYMENT_TARGET=10.0 -DCMAKE_INSTALL_PREFIX=../${install}"
  cmake $td_path $options -DIOS_PLATFORM=${ios_platform} -DCMAKE_TOOLCHAIN_FILE=${td_path}/CMake/iOS.cmake -DIOS_DEPLOYMENT_TARGET=10.0 -DCMAKE_INSTALL_PREFIX=../${install}
  make -j3 install || exit
  cd ..
  fold_end td_build
}

build_macos

build_ios "0" "iOS" & build_ios "1" "iOS" & wait

make_lipo "iOS"
copy_installs "iOS"

cd ..

rm -rf lib/*
rm -rf include/
cp build/iOS/*.a lib/
cp -r build/iOS/include include
cp third_party/openssl/iOS/lib/* lib/

cp td/td/generate/scheme/td_api.tl .

# rm -rf td
# rm -rf third_party
# rm -rf Python-Apple-Support
# rm -rf build
