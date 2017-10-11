#!/bin/bash

set -x -e

source ~/.bashrc

BUILD_ROOT=$PWD
export BUILD_ROOT

bosh -u x -p x target $BOSH_TARGET lite
bosh login $BOSH_USERNAME $BOSH_PASSWORD

wget https://github.com/cloudfoundry-incubator/spiff/releases/download/v1.0.7/spiff_linux_amd64
mkdir bin
mv spiff_linux_amd64 bin/spiff
chmod 755 bin/spiff

export VERSION=$(date +"%y.%m%d.%H%M")
export PATH=$PATH:~/bin
export DEA_HM_WS=${BUILD_ROOT}/cf-release/src/dea-hm-workspace

# HACK to remove 8.8.8.8 from etc/resolv.conf
sed -i 4'i\
### temporary DNS fix ### \
echo "10.244.0.34 api.bosh-lite.com" >> /etc/hosts \
\
echo "nameserver 10.0.80.12" > /etc/resolv.conf \
echo "options single-request" >> /etc/resolv.conf \
######################### \
' cf-release/jobs/acceptance-tests/templates/run.erb

(cd cf-release/src && rm -rf dea-hm-workspace && ln -s ../../dea-hm-workspace dea-hm-workspace)

pushd cf-release
  for i in {1..5}; do
    echo "Syncing blobs, attempt $i"
    bosh -n --parallel 10 sync blobs && break
  done

  bosh create release --force --name cf --with-tarball --version $VERSION
  scripts/generate-bosh-lite-dev-manifest ../runtime-og-ci/runtime-og/stubs/bosh-lite.yml
popd

ls -l cf-release/dev_releases/cf/cf-*.tgz
mv cf-release/dev_releases/cf/cf-*.tgz  assets/release.tgz
mv cf-release/bosh-lite/deployments/cf.yml assets/cf.yml

bosh -n cleanup --all
