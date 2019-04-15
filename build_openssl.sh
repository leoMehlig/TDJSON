
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
      sleep 300
  done
}

git clone https://github.com/pybee/Python-Apple-support
cd Python-Apple-support
git checkout 2.7
git checkout 60b990128d5f1f04c336ff66594574515ab56604
cd ..

platforms="macOS iOS"
for platform in $platforms;
do
  fold_start openssl.2 "Building OpenSSL for ${platform}"
  echo $platform
  cd Python-Apple-support
  make OpenSSL-$platform &> /dev/null & show_progress
  cd ..
  rm -rf third_party/openssl/$platform
  mkdir -p third_party/openssl/$platform/lib
  cp ./Python-Apple-support/build/$platform/libcrypto.a third_party/openssl/$platform/lib/
  cp ./Python-Apple-support/build/$platform/libssl.a third_party/openssl/$platform/lib/
  cp -r ./Python-Apple-support/build/$platform/Support/OpenSSL/Headers/ third_party/openssl/$platform/include
  fold_end openssl.2
done