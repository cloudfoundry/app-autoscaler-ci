#!/bin/bash

set -x

source ~/.bashrc

bosh -u x -p x target $BOSH_TARGET lite
bosh login $BOSH_USERNAME $BOSH_PASSWORD

bosh download manifest cf-warden cf.yml
bosh -d cf.yml run errand $ERRAND_NAME
