#!/bin/sh

setup_git() {
  git config --global user.email "ci@leomehlig.com"
  git config --global user.name "ci-leomehlig"
}

commit_website_files() {
  git checkout master
  git pull
  git add *
  git commit -m $TRAVIS_TAG\ release
}

upload_files() {
  git remote add origin-master git@github.com:leoMehlig/TDJSON.git
  git push origin-master master
}

setup_git
commit_website_files
upload_files