#!/bin/bash
set -x

source ~/.bashrc
source runtime-og-ci/runtime-og/scripts/warden-setup.sh

trap_add() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            extract_trap_cmd() { printf '%s\n' "$3"; }
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
            printf '%s\n' "${trap_add_cmd}"
        )" "${trap_add_name}" \
            || fatal "unable to add to trap ${trap_add_name}"
    done
}

setup_warden_infrastructure

apt-get update
apt-get install -y iptables quota --no-install-recommends

export PATH=$PATH:/sbin

git config --system user.email "nobody@example.com"
git config --system user.name "Anonymous Coward"

rm -rf dea_next/go/{bin,pkg}/*

export GOPATH=$PWD/dea_next/go
export PATH=$PATH:$GOPATH/bin:$HOME/bin

tar -xf rootfs/cf*tar.gz -C /tmp/warden/rootfs

pushd dea-hm-workspace/src/warden/warden
    gem install bundler -v '1.11.2' --no-doc --no-ri
    sed -i s/254/253/g config/linux.yml
    bundle install
    bundle exec rake setup:bin
    bundle exec rake warden:start[config/linux.yml] &> /tmp/warden.log &
    warden_pid=$!
popd

echo "waiting for warden to come up"
while [ ! -e /tmp/warden.sock ]; do
    sleep 1
done
echo "warden is ready"

cd dea_next/
bundle install --without development

export PATH=$PWD/go/bin:$PATH
go get github.com/nats-io/gnatsd
bundle exec foreman start &> /tmp/foreman.log &
dea_pid=$!

trap_add 'kill -9 ${dea_pid}; kill -9 ${warden_pid}' EXIT

bundle exec rspec spec/integration --format documentation
