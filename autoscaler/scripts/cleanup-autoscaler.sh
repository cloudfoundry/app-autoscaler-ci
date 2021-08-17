#!/bin/bash

set -euo pipefail
set -x

cf api https://api.${SYSTEM_DOMAIN} --skip-ssl-validation

CF_ADMIN_PASSWORD=$(credhub get -n /bosh-autoscaler/cf/cf_admin_password -q)
cf auth admin $CF_ADMIN_PASSWORD

set +e
pushd app-autoscaler-release/src/acceptance
  ./cleanup.sh
popd
set -e

set +e
SERVICE_BROKER_EXISTS=$(cf service-brokers | grep -c autoscalerservicebroker.${SYSTEM_DOMAIN}) 
set -e
if [[ $SERVICE_BROKER_EXISTS == 1 ]]; then
  echo "Service Broker already exists, deleting..."
  cf delete-service-broker autoscaler -f
fi

pushd autoscaler-env-bbl-state/bbl-state
  eval "$(bbl print-env)"
popd

set +e
bosh delete-deployment -d app-autoscaler
set -e
