#!/bin/bash

set -euo pipefail

pushd bbl-state/bbl-state
  eval "$(bbl print-env)"
popd

bosh logs -d "${DEPLOYMENT}" --num=100