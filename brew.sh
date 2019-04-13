#!/bin/sh

fold_start() {
  echo -e "travis_fold:start:$1\033[33;1m$2\033[0m"
}

fold_end() {
  echo -e "\ntravis_fold:end:$1\r"
}
fold_start brew "Update and install brew deps"
brew update
brew outdated carthage || brew upgrade carthage
brew install pv
fold_end brew