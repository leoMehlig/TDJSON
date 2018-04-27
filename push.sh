#!/bin/sh

setup_git() {
  git config --global user.email "ci@leomehlig.com"
  git config --global user.name "ci-leomehlig"
}

commit_website_files() {
  git checkout -b master
  git commit * -m CI\ commit\
}

upload_files() {
  git remote add origin git@github.com:leoMehlig/TDJSON.git > /dev/null 2>&1
  git push --quiet --set-upstream origin master
}

setup_git
commit_website_files
upload_files