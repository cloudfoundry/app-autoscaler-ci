#!/bin/bash
set -x

source runtime-og-ci/runtime-og/scripts/warden-setup.sh

setup_warden_infrastructure

apt-get update
apt-get install -y iptables quota --no-install-recommends

source ~/.bashrc

export PATH=$PATH:/sbin

git config --system user.email "nobody@example.com"
git config --system user.name "Anonymous Coward"

tar -xf rootfs/cf*.tar.gz -C /tmp/warden/rootfs

exec 0>&-

export WROOT=$PWD/warden

cd $WROOT/em-posix-spawn
bundle install
rake test

cd $WROOT/warden
gem install bundler -v '1.11.2' --no-rdoc --no-ri
bundle install
bundle exec rake setup:bin
bundle exec rake spec
