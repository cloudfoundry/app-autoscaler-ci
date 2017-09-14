#!/bin/bash

set -e -x

service rsyslog restart

mkdir $HOME/bin
export GOPATH=$PWD/dea-hm-workspace
export PATH=$PATH:$GOPATH/bin:$HOME/bin

export BUILD_BASE=$PWD

go install github.com/onsi/ginkgo/ginkgo

wget https://github.com/nats-io/gnatsd/releases/download/v0.7.2/gnatsd-v0.7.2-linux-amd64.tar.gz
tar xzvf gnatsd-v0.7.2-linux-amd64.tar.gz
mv ./gnatsd $HOME/bin/.

wget https://github.com/coreos/etcd/releases/download/v2.2.4/etcd-v2.2.4-linux-amd64.tar.gz
tar xvzf etcd-v2.2.4-linux-amd64.tar.gz
mv etcd-v2.2.4-linux-amd64/etcd $HOME/bin/.

wget https://releases.hashicorp.com/consul/0.5.2/consul_0.5.2_linux_amd64.zip
unzip consul_0.5.2_linux_amd64.zip -d $HOME/bin

(cd dea-hm-workspace/src/github.com/cloudfoundry && mv hm9000 hm9000.sav && ln -s $BUILD_BASE/hm9000 hm9000)
cd dea-hm-workspace/src/github.com/cloudfoundry/hm9000
ginkgo -r -p -skipMeasurements -race
