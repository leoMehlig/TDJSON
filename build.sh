!/bin/sh

git clone https://github.com/pybee/Python-Apple-support
cd Python-Apple-support
git checkout 2.7
cd ..

platforms="macOS iOS"
for platform in $platforms;
do
  echo $platform
  cd Python-Apple-support
  make OpenSSL-$platform
  cd ..
  rm -rf third_party/openssl/$platform
  mkdir -p third_party/openssl/$platform/lib
  cp ./Python-Apple-support/build/$platform/libcrypto.a third_party/openssl/$platform/lib/
  cp ./Python-Apple-support/build/$platform/libssl.a third_party/openssl/$platform/lib/
  cp -r ./Python-Apple-support/build/$platform/Support/OpenSSL/Headers/ third_party/openssl/$platform/include
done

git clone https://github.com/tdlib/td

td_path=$(pwd)/td

rm -rf build
mkdir -p build
cd build

platforms="iOS"
for platform in $platforms;
do
  echo "Platform = ${platform} Simulator = ${simulator}"
  openssl_path=$(pwd)/../third_party/openssl/${platform}
  echo "OpenSSL path = ${openssl_path}"
  openssl_crypto_library="${openssl_path}/lib/libcrypto.a"
  openssl_ssl_library="${openssl_path}/lib/libssl.a"
  options="$options -DOPENSSL_FOUND=1"
  options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
  #options="$options -DOPENSSL_SSL_LIBRARY=${openssl_ssl_library}"
  options="$options -DOPENSSL_INCLUDE_DIR=${openssl_path}/include"
  options="$options -DOPENSSL_LIBRARIES=${openssl_crypto_library};${openssl_ssl_library}"
  options="$options -DCMAKE_BUILD_TYPE=Release"
  if [[ $platform = "macOS" ]]; then
    build="build-${platform}"
    install="install-${platform}"
    # rm -rf $build
    # mkdir -p $build
    # mkdir -p $install
    # cd $build
    # cmake $td_path $options -DCMAKE_INSTALL_PREFIX=../${install}
    # make -j3 install || exit
    # cd ..
  else
    simulators="0 1"
    for simulator in $simulators;
    do
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
      cmake $td_path $options -DIOS_PLATFORM=${ios_platform} -DCMAKE_TOOLCHAIN_FILE=${td_path}/CMake/iOS.cmake -DIOS_DEPLOYMENT_TARGET=10.0 -DCMAKE_INSTALL_PREFIX=../${install}
      make -j3 install || exit
      cd ..
    done
    mkdir -p $platform
    libs="libtdclient.a libtdsqlite.a libtdcore.a libtdactor.a libtdutils.a libtdjson_private.a libtddb.a libtdjson_static.a libtdnet.a"
    for lib_path in  $libs;
    do
        lib="install-${platform}/lib/${lib_path}"
        lib_simulator="install-${platform}-simulator/lib/${lib_path}"
        echo "lipo -create $lib $lib_simulator -o $platform/$lib_path"
        lipo -create $lib $lib_simulator -o $platform/$lib_path
    done
  fi

  mkdir -p $platform/include
  echo "rsync --recursive ${install}/include/ ${platform}/include/"
  rsync --recursive ${install}/include/ ${platform}/include/
done
cd ..

rm -rf lib/*
rm -rf include/
cp build/iOS/*.a lib/
cp -r build/iOS/include include
cp third_party/openssl/iOS/lib/* lib/

cp td/td/generate/scheme/td_api.tl .